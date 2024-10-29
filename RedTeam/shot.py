import asyncio
from bleak import BleakClient, BleakScanner
#from crccheck.crc import Crc16CcittFalse    


#MODEL_NBR_UUID = "2A24"
counted = set()
known_man= {
    "0x4c": "Apple Device",
    "0x6": "Samsung Device",
    "0x3c1": "Ember Technologies",
    "0x842": "Dragon Hearing Aids"
}



async def scan(address):
    
    
    print("Scanning for Bluetooth devices...\n")
    print(f"{'Name':<20} {'Address':<20} {'RSSI':<20} {'Man. ID':<20} {'TX Power Level':<20}")  # Header
    print("-" * 90)  # Separator line

    # Start the scanner
    async with BleakScanner() as scanner:
        async for device, advertisement_data in scanner.advertisement_data():
            
            if device.address == address: 
                device_info_gather(device, advertisement_data)
                await asyncio.sleep(2)
                await connect(address)
                break
            
            else:
                await device_info_gather(device, advertisement_data)
                


async def device_info_gather(device, advertisement_data):
    man_id = "N/A"
    device_addr = device.address
    rssi = advertisement_data.rssi 
    man_info = advertisement_data.manufacturer_data
    power = advertisement_data.tx_power
    
    if device_addr not in counted:
        counted.add(device_addr)
        device_name = device.name if device.name else "Unknown" 
        rssi = str(rssi) + " dBm"
        if man_info:
            for key,_ in man_info.items():
                man_id = str(hex(key)[:6])
                if man_id in known_man:
                    man_id = known_man[man_id]
                else:
                    man_id = man_id
        print(f"{device_name:<20} {device_addr:<20} {rssi:<20} {man_id:<20} {power}")




async def connect(address):
    #Establish connection to device with line below
    try:
        print(f"Attempting to connect to device with address: {address}")
        async with BleakClient(address) as client:
            # Read a characteristic, etc.
            services = await client.get_services()
            for service in services:
                print(service)
        
    except Exception as e:
        print(f" Failed to connect to device with address: {address}: {e}")
 
    
    

async def main():
    address = "C2:4A:DA:A9:F2:48"
    #Left Hearing Aid: C2:4A:DA:A9:F2:48
    #Right Hearing Aid: CF:4A:CB:22:38:23
    #Begin the scan for devices
    await scan(address)

if __name__ == "__main__":
    asyncio.run(main())
    


#TODO Import pyshark to then be able to analyze the packets from the device and the hearing aids. 



#TODO Check and see if I can write to the device prior to connection.

