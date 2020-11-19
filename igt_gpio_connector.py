
import time

from threading import Thread
from random import choice
from string import ascii_lowercase

from thingsboard_gateway.connectors.connector import Connector, log    # Import base class for connector and logger


class IGT_GPIOConnector(Thread, Connector):
    def __init__(self, gateway, config, connector_type):
        super().__init__()
        self.statistics = {'MessagesReceived': 0,
                           'MessagesSent': 0}    # Dictionary, will save information about count received and sent messages.
        log.debug(type(config))
        log.debug(config)
        self.__config = config    # Save configuration from the configuration file.
        log.debug(type(gateway))
        log.debug(gateway)
        self.__gateway = gateway    # Save gateway object, we will use some gateway methods for adding devices and saving data from them.
        self.daemon = True    # Set self thread as daemon
        self.stopped = True    # Service variable for check state
        #self.__connected = False    # Service variable for check connection to device
        self.__devices = {}
        self.setName(self.__config.get("name",
                                       'IGT GPIO Default ' + ''.join(choice(ascii_lowercase) for _ in range(5))))
        self.__load_converters()
        log.info('Custom connector %s initialization success.', self.get_name())    # Message to logger
        log.info("Devices in configuration file found: %s ", '\n'.join(device for device in self.__devices))    # Message to logger

    def open(self):    # Function called by gateway on start
        self.stopped = False
        log.info("Starting Custom %s connector", self.get_name())    # Send message to logger
        self.start()

    def get_name(self):    # Function used for logging, sending data and statistic
        return self.name

    def is_connected(self):    # Function for checking connection state
        pass

    def run(self):    # Main loop of thread
        log.info("%s connected.", self.get_name())
        while True:
            time.sleep(.01)
            for device in self.__devices:
                current_time = time.time()
                to_send = {}
                try:
                    if self.__devices[device]["config"].get("timeseries") is not None:
                        if self.__devices[device]["next_timeseries_check"] < current_time:
                            #  Reading data from device
                            tmp_list = []
                            for index in range(len(self.__devices[device]["config"]["timeseries"])):
                                channel = self.__devices[device]["config"]["timeseries"][index] # channel is a dict
                                address = channel["address"]
                                devFile = "/sys/class/gpio/gpio" + str(address) + "/value"
                                f = open(devFile, "r")
                                ret = f.read()
                                f.close()
                                if channel["inversion"]:
                                    ret = 1 - int(ret) # invert ret
                                else:
                                    ret = int(ret)
                                tmp_list.append({channel["tag"]: ret})

                            self.__devices[device]["next_timeseries_check"] = current_time + self.__devices[device]["config"]["timeseriesPollPeriod"]/1000

                            if self.__devices[device]["config"].get("sendDataOnlyOnChange"):
                                self.statistics['MessagesReceived'] += 1
                                to_send = {'deviceName': device, 'deviceType': 'default'}
                                if to_send.get("telemetry") is None:
                                    to_send["telemetry"] = []
                                if to_send.get("attributes") is None:
                                    to_send["attributes"] = []
                                for telemetry_dict in tmp_list:
                                    for key, value in telemetry_dict.items():
                                        if self.__devices[device]["last_telemetry"].get(key) is None or \
                                           self.__devices[device]["last_telemetry"][key] != value:
                                            self.__devices[device]["last_telemetry"][key] = value
                                            to_send["telemetry"].append({key: value})
                                if not to_send.get("attributes") and not to_send.get("telemetry"):
                                    log.debug("Data has not been changed.")
                            elif self.__devices[device]["config"].get("sendDataOnlyOnChange") is None or not self.__devices[device]["config"].get("sendDataOnlyOnChange"):
                                self.statistics['MessagesReceived'] += 1
                                to_send = {'deviceName': device, 'deviceType': 'default'}
                                to_send["telemetry"] = tmp_list
                                to_send["attributes"] = []

                    if to_send.get("attributes") or to_send.get("telemetry"):
                        self.__gateway.send_to_storage(self.get_name(), to_send)
                        self.statistics['MessagesSent'] += 1

                except Exception as e:
                    log.exception(e)

    def close(self):    # Close connect function, usually used if exception handled in gateway main loop or in connector main loop
        self.stopped = True
        pass

    def on_attributes_update(self, content):    # Function used for processing attribute update requests from ThingsBoard
        pass

    def server_side_rpc_handler(self, content):
        log.debug(type(content))
        log.debug(content)
        hit = False
        try:
            if content.get("device") is not None:

                log.debug("IGT GPIO connector received rpc request for %s with content: %s", content["device"], content)
                if isinstance(self.__devices[content["device"]]["config"]["rpc"], list):
                    for rpc_command_config in self.__devices[content["device"]]["config"]["rpc"]:
                        log.debug(type(rpc_command_config))
                        log.debug(rpc_command_config)
                        if rpc_command_config["tag"] == content["data"]["method"]:
                            hit = True
                            self.__process_rpc_request(content, rpc_command_config)
                            break
                    if not hit:
                        log.error("Received rpc request, but method %s not found in config for %s.",
                                  content["data"].get("method"),
                                  self.get_name())
                        self.__gateway.send_rpc_reply(content["device"],
                                                      content["data"]["id"],
                                                      {content["data"]["method"]: "Error, method not found!"})
                else:
                    log.error("Received rpc request, but method %s not found in config for %s.",
                              content["data"].get("method"),
                              self.get_name())
                    self.__gateway.send_rpc_reply(content["device"],
                                                  content["data"]["id"],
                                                  {content["data"]["method"]: "Error, method not found!"})
            else:
                log.debug("Received RPC to connector: %r", content)
        except Exception as e:
            log.exception(e)

    def __process_rpc_request(self, content, rpc_command_config):
        if rpc_command_config is not None:
            log.debug(rpc_command_config)
            address = rpc_command_config["address"]
            response = None
            try:
                if content["data"].get("params") is not None:
                    params = content["data"]["params"]
                    if not isinstance(params, bool):
                        log.error("Received rpc request, but params is not bool for method %s!", content["data"].get("method"))
                        self.__gateway.send_rpc_reply(content["device"],
                                                      content["data"]["id"],
                                                      {content["data"]["method"]: "Error, params is not bool!"})
                        return
                    inversion = rpc_command_config["inversion"]
                    result = (params != inversion) # params XOR inversion
                    f = open("/sys/class/gpio/gpio" + str(address) + "/value", "w")
                    if result:
                        ret = f.write("1")
                    else:
                        ret = f.write("0")
                    f.close()
                    response = {"success": True}
                else:
                    log.error("Received rpc request, but no params found for method %s!", content["data"].get("method"))
                    self.__gateway.send_rpc_reply(content["device"],
                                                  content["data"]["id"],
                                                  {content["data"]["method"]: "Error, no params found!"})
                    return
            except Exception as e:
                log.exception(e)
                response = e
            if content.get("id") or (content.get("data") is not None and content["data"].get("id")):
                if isinstance(response, Exception):
                    log.error("Received rpc request, but exception happened for method %s!", content["data"].get("method"))
                    self.__gateway.send_rpc_reply(content["device"],
                                                  content["data"]["id"],
                                                  {content["data"]["method"]: str(response)})
                else:
                    self.__gateway.send_rpc_reply(content["device"],
                                                  content["data"]["id"],
                                                  response)

    def __load_converters(self):
        try:
            for device in self.__config["devices"]:
                if device.get('deviceName') not in self.__gateway.get_devices():
                    self.__gateway.add_device(device.get('deviceName'), {"connector": self})
                self.__devices[device["deviceName"]] = { "config": device,
                                                         "next_timeseries_check": 0, # for timeseriesPollPeriod
                                                         "last_telemetry": {} # for sendDataOnlyOnChange
                                                         }
        except Exception as e:
            log.exception(e)
