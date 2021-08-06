#!/usr/bin/python3.7


#print("Hello world!")
import time

PeicePerSencond = 1 #每秒传送时间信息的条数
#get current time(dat and time)
#curTime = time.gmtime()

#str_whole=time.strftime("%Y%m%d %H%M%S", curTime)
#print(str_whole)
#print(curTime)

def getData():
    curTime = time.ctime()
    print(curTime)
    temp = time.strptime(curTime, "%a %b %d %H:%M:%S %Y")
    str_format = time.strftime("%Y%m%d %H%M%S", temp)
    print(str_format)
    DateTime = str_format.split(" ")
    Date = DateTime[0]
    Time = DateTime[1]
    #print(Date, Time)
    data_str = Date + "#" + Time
    print(data_str)
    data = [0x7e]
	#data = []
    for i in range(len(data_str)):
        if data_str[i]!="#":
            BCD = int(data_str[i])
            data.append(BCD)
        else:
            data.append(0x88)
	#data.append(0x7e)
	#data = bytearray(data)
    print(data)
    return data

#exit(0)
import serial
ser = serial.Serial(port="/dev/ttyAMA1", baudrate=115200
        ,timeout=1E-7, parity=serial.PARITY_EVEN, stopbits=1
        ,bytesize=8)
print(ser.parity, ser.bytesize, ser.stopbits)
if True:
    while True:
        data = getData()
        for i, zhen in enumerate(data):
            try:
                ser.write(bytes([zhen]))
				#ser.read(ser.inWaiting())
                print("------{}th  TRASMIST SUCCEED-------".format(i+1))
				#print(bytearray([zhen]))
                time.sleep(5E-7)
				#text=ser.read(ser.inWaiting())
				#if text:
				#print("--{}th  receive succedd--".format(i+1))
                #print("RECEIVERD INFORMATION: ", text)
            except:
                print("ERROR: UART information sent failed!!")
				#print(ser.inWaiting())
			
            time.sleep(5E-7)
		
        time.sleep(1/PeicePerSencond-1E-6)