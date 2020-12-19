#!/usr/bin/env python
from serial import Serial, EIGHTBITS, PARITY_NONE, STOPBITS_ONE
from sys import argv

assert len(argv) == 2
s = Serial(
    port=argv[1],
    baudrate=115200,
    bytesize=EIGHTBITS,
    parity=PARITY_NONE,
    stopbits=STOPBITS_ONE,
    xonxoff=False,
    rtscts=False
)

fp = open('mountain.bmp', 'rb')
fw = open('image.out', 'wb')
assert fp and fw

image = fp.read()
print(len(image))
#fw.write(image)

for i in range(0, len(image)):
    s.write(image[i:i+8])
    #fw.write(image[i:i+8])
    #print(len(image[i]))

fp.close()
fw.close()
