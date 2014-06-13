from BlinkyTape import BlinkyTape
from BlinkyBlock import BlinkyBlock
import SawsConfig
from threading import Timer
import glob
import sys

class SawsDisplay:
    
    blocks = []
    
    def __init__(self):
        print "SawsDisplay on serial", SawsConfig.SERIAL_PORT
        serialPorts = glob.glob(SawsConfig.SERIAL_PORT)
        try:
            port = serialPorts[0]
            self.bt = BlinkyTape(port)
            self.status = [999, 999, 999]
            len = id = idx = 0
            for i in SawsConfig.LENGTHS:
                self.blocks.append(BlinkyBlock(idx, 1))
                idx = idx+1
                self.blocks.append(BlinkyBlock(idx, SawsConfig.LENGTHS[id]))
                len = len + 1 + SawsConfig.LENGTHS[id]
                idx = idx + SawsConfig.LENGTHS[id]
                id = id+1
            self.blocks.append(BlinkyBlock(idx, 1))
            len = len + 1
            if len > SawsConfig.MAX_LEDS:
                raise Exception("Max LEDs is {}, you specified {}".format(SawsConfig.MAX_LEDS, len))
                sys.exit(0)
            self.draw()
        except IndexError:
            print"Could not connect to Blinkytape on serial", SawsConfig.SERIAL_PORT
            sys.exit(0)
        
        
    def update(self, status):
        self.status = status
        
    def draw(self):
        t = Timer(SawsConfig.REDRAW_SPEED, self.draw)
        t.start()
        currentBlock = 0
        for i in range(0, len(self.blocks)):
            if (i%2==0): self.blocks[i].draw(self.bt, 5)
            else:
                self.blocks[i].draw(self.bt, self.status[currentBlock])
                currentBlock = currentBlock + 1
        self.bt.sendUpdate()
        