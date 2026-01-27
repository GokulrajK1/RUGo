from passiogo.rutgers_passiogo_client import RutgersPassioGOClient, RutgersBus, Coordinate
import time
from datetime import datetime
from zoneinfo import ZoneInfo

class BusLogger:
    def __init__(self, timezone_str='US/Eastern'):
        self.client = RutgersPassioGOClient()
        self.timezone = ZoneInfo(timezone_str)

    def encode_bus(self, bus : RutgersBus) -> str:
        if bus is None:
            return ""
        timestamp = datetime.now(self.timezone).isoformat()
        data = [timestamp, bus.id, bus.route_id, bus.name, bus.position_coord.lat, 
                bus.position_coord.long, bus.pax_load, bus.total_capacity, 
                bus.speed_in_mph, bus.heading_in_degrees, bus.is_out_of_service, 
                bus.is_outdated, bus.route_block_id]
        
        string = ""
        for item in data:
            string += str(item) + "|"
        return string[:-1] + "\n"
    
    def decode_bus(self, encoded_bus : str) -> RutgersBus:
        if not encoded_bus:
            return None
        data = encoded_bus.strip().split("|")
        timestamp_str = data[0]
        timestamp = datetime.fromisoformat(timestamp_str) if timestamp_str and timestamp_str != 'None' else None
        lat_str = data[4]
        long_str = data[5]
        position_coord = Coordinate(float(lat_str), float(long_str)) if lat_str != 'None' and long_str != 'None' else None
        bus = RutgersBus(
            id = data[1],
            route_id = data[2],
            name = data[3],
            position_coord = position_coord,
            pax_load = int(data[6]),
            total_capacity = int(data[7]),
            speed_in_mph = float(data[8]),
            heading_in_degrees = float(data[9]),
            is_out_of_service = data[10] == "True",
            is_outdated = data[11] == "True",
            route_block_id = data[12],
            timestamp = timestamp
        )
        return bus

    def log(self) -> str:
        buses = self.client.get_buses()
        encoded_buses = ""
        for bus in buses:
            encoded_bus = self.encode_bus(bus)
            encoded_buses += encoded_bus
        return encoded_buses

        
if __name__ == "__main__":
    bus_logger = BusLogger()
    interval_seconds = 30
    file_path = "test.txt"
    try:
        print("Starting bus logger. Press Ctrl+C to stop.")
        while True:
            decoded_buses = bus_logger.log()
            with open(file_path, "a") as f:
                f.write(decoded_buses)
            time.sleep(interval_seconds)
    except KeyboardInterrupt:
        print("Logger stopped by user (Ctrl+C).")


