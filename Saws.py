from BlinkyTape import BlinkyTape
from SawsDisplay import SawsDisplay
import SawsConfig
from threading import Timer
import time
import glob

class Saws:
    
    def __init__(self):
        self.display = SawsDisplay()
        
    def start(self):
        print "Saws start", time.strftime("%c")
        self.load()
        
    def load(self):
        t = Timer(SawsConfig.RELOAD_DELAY, self.load)
        t.start()
        status = []
        for i in SawsConfig.LOG_FILES:
            with open(SawsConfig.LOG_DIR+i, 'r') as f:
                result = f.read()
                status.append(int(result))
        self.display.update(status)
        
    def stop(self):
        print "Saws stop"
        
    def __del__(self):
        self.stop()
        
if __name__ == "__main__":
    
    saws = Saws()
    saws.start()
    