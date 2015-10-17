LOG_DIR = "logs/"
LOG_FILES = ["jenkinsJobStatus", "nagiosStatus", "travisJobStatus_MyAwesomeRepo"]
RELOAD_DELAY = 5.0 # reload log files in seconds
STATUS_UPDATE_FAILURE = 120.0 # unless status = 3

# change this to the USB port your BlinkyTape is on
SERIAL_PORT = "/dev/tty.usbmodem1411"
MAX_LEDS = 60
LENGTHS = [18, 18, 20]
BLINK_SPEED = 180

REDRAW_SPEED = 0.01

COLOURS = {"red" :      [255, 0, 0], 
           "green" :    [0, 255, 0], 
           "blue" :     [0, 0, 255], 
           "yellow" :   [255, 255, 0], 
           "pink" :     [255, 32, 32]}

EFFECTS = ["static", 
           "flashing", 
           "pulsing", 
           "nightrider", 
           "random"]

STATUS = {0 :   ["green", "static"], 
          1 :   ["yellow", "static"],
          2 :   ["red", "flashing"], 
          3 :   ["pink", "nightrider"], 
          4 :   ["green", "random"], 
          5 :   ["blue", "pulsing"], 
          6 :   ["red", "static"], 
          7 :   ["blue", "nightrider"], 
          999 : ["pink", "static"]}