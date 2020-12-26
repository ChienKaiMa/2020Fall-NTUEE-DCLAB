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

fp = open('mountain.bin', 'rb')
fw = open('image.out', 'wb')
assert fp

image = fp.read()
print(len(image))
#fw.write(image)
#s.write(image)

for i in range(1077, len(image)):
    s.write(image[i])
    fw.write(image[i])
    #print(len(image[i]))

fp.close()
fw.close()
