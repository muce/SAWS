from BlinkyTape import BlinkyTape
import SawsConfig
import random
import math

class BlinkyBlock:
    
    def __init__(self, start, length):
        self.start = start
        self.length = length
        self.cells = []
        for i in range(self.length):
            self.cells.append([])
        self.speed = SawsConfig.BLINK_SPEED
        self.phase = 0
        self.currentCell = 0
        self.dir = True
        
    def draw(self, bt, status):
        colour = SawsConfig.COLOURS[SawsConfig.STATUS[status][0]]
        effect = SawsConfig.STATUS[status][1]
        for i in range(self.length):
            if effect == "static":
                self.cells[i] = colour
            elif effect == "flashing":
                if self.phase >= self.speed/2:
                    self.cells[i] = [0, 0, 0]
                else:
                    self.cells[i] = colour
            elif effect == "nightrider":
                if i==self.currentCell:
                    self.cells[i] = colour
                else:
                    self.cells[i] = [32, 32, 32]
                if (i-self.currentCell<5) and (i-self.currentCell>0):
                    diff = 1 #5*(i-self.currentCell)
                    self.cells[i] = [int(colour[0]/diff), int(colour[1]/diff), int(colour[2]/diff)]
                else:
                    self.cells[i] = [0, 0, 0]
            elif effect == "pulsing":
                val = (1+math.sin(2*math.pi*self.phase/self.speed))/2
                self.cells[i] = [int(val*colour[0]), int(val*colour[1]), int(val*colour[2])]
            elif effect == "random":
                self.cells[i] = [random.randrange(0, 255), random.randrange(0, 255), random.randrange(0, 255)]
            bt.setPixel(i+self.start, self.cells[i][0], self.cells[i][1], self.cells[i][2])
        
        if self.phase%4==0:
            if self.dir is True:
                self.currentCell = self.currentCell + 1
                if self.currentCell == self.length-5:
                    self.dir = not self.dir
            else:
                self.currentCell = self.currentCell - 1
                if self.currentCell == -1:
                    self.dir = not self.dir

        self.phase = self.phase + 1
        if self.phase == self.speed:
            self.phase = 0
            
    def getCells(self):
        self.cells
        