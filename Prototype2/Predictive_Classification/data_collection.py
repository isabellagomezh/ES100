import serial
import time
import csv

file = 'final_tests/jerry_arm_rotation_170Hz.csv'

with open(file, mode='a') as sensor_file:
    sensor_writer = csv.writer(sensor_file, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
    sensor_writer.writerow(["Time", "Value"])
    
port = "/dev/cu.usbmodem1101"
port2 = "/dev/cu.usbmodem101"
baud = 115200

x = serial.Serial(port, baud, timeout=0.1)
y = serial.Serial(port2, baud, timeout=0.1)

start_time = time.time() * 1000  # seconds to milliseconds

while x.isOpen() and y.isOpen():
# while x.isOpen():
    data = str(x.readline().decode('utf-8')).rstrip()
    data2 = str(y.readline().decode('utf-8')).rstrip()
    if data and data2:
    # if data:
        print(data + ", " + data2)
        # print(data)
        # Calculate the timestamp in milliseconds since the start of the recording
        timestamp = int((time.time() * 1000) - start_time)
        with open(file, mode='a') as sensor_file:
            sensor_writer = csv.writer(sensor_file, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
            sensor_writer.writerow([timestamp, data, data2])
            # sensor_writer.writerow([timestamp, data])

# while x.isOpen() is True:
#     data = str(x.readline().decode('utf-8')).rstrip()
#     if data is not '':
#         print(data)
#         with open('wrist_test1.csv', mode='a') as sensor_file:
#             sensor_writer = csv.writer(sensor_file, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
#             sensor_writer.writerow([str(data), str(time.asctime())])