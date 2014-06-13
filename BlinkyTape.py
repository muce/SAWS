# Modified version of the BlinkyTape Python example code from github.com/Blinkinlabs/BlinkyTape_Python
# Created by Matt Dyson (mattdyson.org)
# Version 1.0 (20/12/13)

import serial

class BlinkyTape(object):
  def __init__(self, port, ledCount = 60):
    self.port = port
    self.ledCount = ledCount
    # Initialise the LED buffer
    self.led = []
    for i in range(0, self.ledCount):
       self.led.append([0,0,0])
    self.serial = serial.Serial(port, 115200)
    self.sendUpdate()

  # Set a specified pixel to a specified RGB value in our buffer. 
  # If final argument==True, then push update to the strip
  def setPixel(self, pixel, r, g, b, autoUpdate=False):
    self.led[pixel]=[r,g,b]
    if autoUpdate:
       self.sendUpdate()

  # Update the strip to match our current buffer
  def sendUpdate(self):
    data = ""
    for i in range(0, self.ledCount):
       for c in range(3):
          if self.led[i][c]>254:
             self.led[i][c]=254
          if self.led[i][c]<0:
             self.led[i][c]=0
          data+=chr(self.led[i][c])
    data+=chr(0)+chr(0)+chr(255)
    self.serial.write(data)
    self.serial.flush()
    self.serial.flushInput()

  # Turn off all LEDs
  def clear(self):
    self.displayColor(0,0,0)

  # Set all LEDs to the same colour
  def displayColor(self, r, g, b):
    for i in range(0, self.ledCount):
      self.setPixel(i,r,g,b)
    self.sendUpdate()
  
  # Return number of LEDs in our strip
  def getSize(self):
    return self.ledCount

  # Attempt to turn off and close serial connection gracefully on object destruction
  def __del__(self):
    self.clear()
    self.serial.close()
