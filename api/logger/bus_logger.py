from ..passiogo.rutgers_passiogo_client import RutgersPassioGOClient, RutgersBus

class BusLogger:
    def __init__(self):
        self.client = RutgersPassioGOClient()

if __name__ == "__main__":
    bus_logger = BusLogger()
    