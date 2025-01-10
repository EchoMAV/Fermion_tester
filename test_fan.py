import smbus2
import time

# I2C configuration
I2C_BUS = 10  # Use bus 10 since the device is on /dev/i2c-10
EMC2301_ADDR = 0x2F  # The detected I2C address of the EMC2301

# EMC2301 registers
FAN_SPEED_REG = 0x30  # Register for fan speed control (duty cycle)

# Fan speed percentages (adjust as needed)
FAN_SPEEDS = {
    "high": 100,  # Full speed
    "low": 40,  # Low speed
#    "off": 0,  # Fan off
}

def set_fan_speed(speed_percent):
    """Set fan speed by writing to the EMC2301 fan speed register."""
    # Ensure speed percentage is within valid range (0 to 100)
    speed_percent = max(0, min(100, speed_percent))

    # Convert percentage to register value (0-255)
    register_value = int((speed_percent / 100) * 255)

    # Write to fan speed register
    bus.write_byte_data(EMC2301_ADDR, FAN_SPEED_REG, register_value)
    print(f"Fan speed set to {speed_percent}%")

# Initialize I2C bus
bus = smbus2.SMBus(I2C_BUS)

try:
    while True:
        for speed_name, speed_percent in FAN_SPEEDS.items():
            print(f"Setting fan to {speed_name}...")
            set_fan_speed(speed_percent)
            time.sleep(1)
except KeyboardInterrupt:
    print("Exiting...")
    set_fan_speed(0)  # Turn off fan on exit
finally:
    bus.close()
