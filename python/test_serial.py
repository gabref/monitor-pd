import sys
import serial
import serial.serialutil

# Check if the COM port argument is provided
if len(sys.argv) < 2:
    print("Usage: python test_serial.py <COM port>")
    sys.exit(1)

# Get the COM port name from command-line arguments
com_port = sys.argv[1]

# Open the serial connection with a timeout
try:
    ser = serial.Serial(com_port, baudrate=9600, timeout=1)
except serial.serialutil.SerialException as e:
    print(f"Failed to open the serial port: {e}")
    sys.exit(1)

# Convert hex data to bytes
hex_data = '02 07 16 01'
bytes_data = bytes.fromhex(hex_data.replace(' ', ''))

# Send the data
ser.write(bytes_data)

try:
    # Read data from the serial port
    read_data = ser.read(100)  # Read up to 100 bytes
    received_data = read_data.decode('utf-8')

    # Print the received data
    print("Received data:", received_data)

except serial.serialutil.SerialException as e:
    print(f"Error occurred during serial communication: {e}")

finally:
    # Close the serial connection
    ser.close()
