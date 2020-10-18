
import time

from threading import Thread

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
            for device in self.__config["devices"]:
                log.debug(type(device))
                log.debug(device)
                for channel in device["timeseries"]:
                    log.debug(type(channel))
                    log.debug(channel)
                    address = channel["address"]
                    log.debug(type(address))
                    log.debug(address)
                    devFile = "/sys/class/gpio/gpio" + str(address) + "/value"
                    log.debug(type(devFile))
                    log.debug(devFile)
                    f = open(devFile, "r")
                    ret= f.read()
                    f.close()
                    log.debug(type(ret))
                    log.debug(ret)
                    log.debug(type(device.get('deviceName')))
                    log.debug(device.get('deviceName'))
                    to_send = {'deviceName': device.get('deviceName'), 'deviceType': 'default', 'telemetry': [{channel["tag"]: int(ret)}], 'attributes': []    }
                    log.debug(type(to_send))
                    log.debug(to_send)
                    self.__gateway.send_to_storage(self.get_name(), to_send)
            time.sleep(1)


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
        except Exception as e:
            log.exception(e)
