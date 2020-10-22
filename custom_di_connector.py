
import time

from threading import Thread
from random import choice
from string import ascii_lowercase

from thingsboard_gateway.connectors.connector import Connector, log    # Import base class for connector and logger


class CustomDIConnector(Thread, Connector):
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
                                       'DI Default ' + ''.join(choice(ascii_lowercase) for _ in range(5))))
        self.__load_converters()
        log.debug('Custom connector %s initialization success.', self.get_name())    # Message to logger
        #log.info("Devices in configuration file found: %s ", '\n'.join(device for device in self.__devices))    # Message to logger

    def open(self):    # Function called by gateway on start
        self.stopped = False
        self.start()

    def get_name(self):    # Function used for logging, sending data and statistic
        return self.name

    def is_connected(self):    # Function for checking connection state
        pass

    def run(self):    # Main loop of thread
        log.debug("CustomDIConnector run")
        while True:
            time.sleep(.01)
            for device in self.__devices:
                current_time = time.time()
                to_send = {}
                log.debug(type(device))
                log.debug(device)
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
                                ret= f.read()
                                f.close()
                                tmp_list.append({channel["tag"]: int(ret)})

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
                        log.debug(to_send)
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
        pass

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
