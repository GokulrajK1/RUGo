import json
from .passiogo_client import PassioGOClient

"""
Rutgers PassioGO Client Module

This module provides a specialized client for Rutgers University's transit system
using the PassioGO API. It includes classes for representing Rutgers-specific routes,
stops, buses, and ETAs, with filtering for active routes.

Classes:
    - RutgersRouteIds: Constants for Rutgers route IDs.
    - Coordinate: Represents geographic coordinates.
    - RutgersStop: Represents a Rutgers bus stop.
    - RutgersRoute: Represents a Rutgers bus route.
    - RutgersETA: Represents estimated time of arrival.
    - RutgersBus: Represents a Rutgers bus with ETA.
    - RutgersPassioGOClient: Main client for Rutgers transit data.
"""

class RutgersRouteIds():
    """
    Constants for Rutgers route IDs, including active and excluded routes.
    """
    CAMDEN = "41231"
    H = "55368"
    C = "55366"
    REXL = "54551"
    ON1 = "26280"
    ON2 = "26281"
    WKND1 = "26435"
    WKND2 = "26436"
    ALLCAMP = "37199"
    A = "54540"
    REXB = "54550"
    EE = "54543"
    F = "54544"
    BL_LOOP = "59451"
    LX = "54545"
    B = "54541"
    CCEXP = "4088"
    CAMPUS_CONNECT = "4063"
    PENN_EXPR = "4098"
    PENN_LOCAL = "4056"

class Coordinate:
    """
    Represents a geographic coordinate with latitude and longitude.
    """
    def __init__(self, latitude: float, longitude: float):
        """
        Initialize a Coordinate.
        
        Args:
            latitude (float): Latitude value.
            longitude (float): Longitude value.
        """
        self.lat = latitude
        self.long = longitude
    def __repr__(self):
        return f"Coordinate(lat={self.lat}, long={self.long})"
    def to_dict(self):
        """
        Convert to dictionary representation.
        
        Returns:
            dict: Dictionary with 'lat' and 'long' keys.
        """
        return {'lat': self.lat, 'long': self.long}

class RutgersStop:
    """
    Represents a Rutgers bus stop with location and route information.
    """
    def __init__(
        self,
        id : str = None,
        route_id : str = None,
        name : str = None,
        position_index : int = None,
        position_coord : Coordinate = None,
    ):
        """
        Initialize a RutgersStop.
        
        Args:
            id (str): Stop ID.
            route_id (str): Associated route ID.
            name (str): Stop name.
            position_index (int): Position index on route.
            position_coord (Coordinate): Geographic coordinates.
        """
        self.id = id
        self.route_id = route_id
        self.name = name
        self.position_index = position_index
        self.position_coord = position_coord

    def __repr__(self):
        return f"RutgersStop(id={self.id}, route_id={self.route_id}, name={self.name}, position_index={self.position_index}, position_coord={self.position_coord})"

    def to_dict(self):
        """
        Convert to dictionary representation.
        
        Returns:
            dict: Dictionary with stop details.
        """
        return {
            'id': self.id,
            'route_id': self.route_id,
            'name': self.name,
            'position_index': self.position_index,
            'position_coord': self.position_coord.to_dict() if self.position_coord else None
        }

class RutgersRoute:
    """
    Represents a Rutgers bus route with stops and coordinates.
    """
    def __init__(
        self, 
        id : str = None, 
        name : str = None,
        short_name : str = None,
        color: str = None,
        stops_list : list[RutgersStop] = None,
        stops_dict : dict[str, RutgersStop] = None,
        coords_list : list[tuple[float, float]] = None
    ):
        """
        Initialize a RutgersRoute.
        
        Args:
            id (str): Route ID.
            name (str): Full route name.
            short_name (str): Short route name.
            color (str): Route color.
            stops_list (list[RutgersStop]): List of stops.
            stops_dict (dict[str, RutgersStop]): Dict of stops by ID.
            coords_list (list[Coordinate]): List of route coordinates.
        """
        self.id = id
        self.name = name
        self.short_name = short_name
        self.color = color
        self.stops_list = stops_list
        self.stops_dict = stops_dict
        self.coords_list = coords_list

    def __repr__(self):
        return f"RutgersRoute(id={self.id}, name={self.name}, short_name={self.short_name}, color={self.color}, stops_count={len(self.stops_list if self.stops_list else [])})"

    def to_dict(self):
        """
        Convert to dictionary representation.
        
        Returns:
            dict: Dictionary with route details.
        """
        return {
            'id': self.id,
            'name': self.name,
            'short_name': self.short_name,
            'color': self.color,
            'stops_list': [stop.to_dict() for stop in self.stops_list] if self.stops_list else [],
            'stops_dict': {k: v.to_dict() for k, v in self.stops_dict.items()} if self.stops_dict else {},
            'coords_list': [coord.to_dict() for coord in self.coords_list] if self.coords_list else []
        }
    
class RutgersETA:
    """
    Represents estimated time of arrival for a Rutgers bus.
    """
    def __init__(
        self,
        eta_description : str = None,
        eta_in_minutes: int = None,
        eta_in_seconds : int = None,
        updated_seconds_ago : int = None,
    ):
        """
        Initialize a RutgersETA.
        
        Args:
            eta_description (str): Text description of ETA.
            eta_in_minutes (int): ETA in minutes.
            eta_in_seconds (int): ETA in seconds.
            updated_seconds_ago (int): Seconds since last update.
        """
        self.eta_description = eta_description
        self.eta_in_minutes = eta_in_minutes
        self.eta_in_seconds = eta_in_seconds
        self.updated_seconds_ago = updated_seconds_ago

    def __repr__(self):
        return f"RutgersETA(eta_description={self.eta_description}, eta_in_minutes={self.eta_in_minutes}, eta_in_seconds={self.eta_in_seconds}, updated_seconds_ago={self.updated_seconds_ago})"

    def to_dict(self):
        """
        Convert to dictionary representation.
        
        Returns:
            dict: Dictionary with ETA details.
        """
        return {
            'eta_description': self.eta_description,
            'eta_in_minutes': self.eta_in_minutes,
            'eta_in_seconds': self.eta_in_seconds,
            'updated_seconds_ago': self.updated_seconds_ago
        }
    
class RutgersBus:
    """
    Represents a Rutgers bus with location, status, and ETA.
    """
    def __init__(
        self,
        id : str = None,
        route_id : str = None,
        route_block_id : str = None,
        name : str = None,
        pax_load : int = None,
        total_capacity : int = None,
        is_out_of_service : bool = None,
        is_outdated : bool = None, 
        heading_in_degrees : float = None,
        speed_in_mph : float = None,
        position_coord : Coordinate = None,
        eta : RutgersETA = None,
    ):
        """
        Initialize a RutgersBus.
        
        Args:
            id (str): Bus ID.
            route_id (str): Route ID.
            route_block_id (str): Route block ID.
            name (str): Bus name.
            pax_load (int): Passenger load percentage.
            total_capacity (int): Total capacity.
            is_out_of_service (bool): Out of service status.
            is_outdated (bool): Outdated status.
            heading_in_degrees (float): Heading in degrees.
            speed_in_mph (float): Speed in mph.
            position_coord (Coordinate): Current position.
            eta (RutgersETA): ETA information.
        """
        self.id = id
        self.route_id = route_id
        self.route_block_id = route_block_id
        self.name = name
        self.pax_load = pax_load
        self.total_capacity = total_capacity
        self.is_out_of_service = is_out_of_service
        self.is_outdated = is_outdated
        self.heading_in_degrees = heading_in_degrees
        self.speed_in_mph = speed_in_mph
        self.position_coord = position_coord
        self.eta = eta 

    def __repr__(self):
        return f"RutgersBus(id={self.id}, route_id={self.route_id}, name={self.name}, pax_load={self.pax_load}, total_capacity={self.total_capacity}, is_out_of_service={self.is_out_of_service}, is_outdated={self.is_outdated}, heading_in_degrees={self.heading_in_degrees}, speed_in_mph={self.speed_in_mph}, position_coord={self.position_coord},\n\teta={self.eta})"

    def to_dict(self):
        """
        Convert to dictionary representation.
        
        Returns:
            dict: Dictionary with bus details.
        """
        return {
            'id': self.id,
            'route_id': self.route_id,
            'route_block_id': self.route_block_id,
            'name': self.name,
            'pax_load': self.pax_load,
            'total_capacity': self.total_capacity,
            'is_out_of_service': self.is_out_of_service,
            'is_outdated': self.is_outdated,
            'heading_in_degrees': self.heading_in_degrees,
            'speed_in_mph': self.speed_in_mph,
            'position_coord': self.position_coord.to_dict() if self.position_coord else None,
            'eta': self.eta.to_dict() if self.eta else None
        }


class RutgersPassioGOClient():
    """
    Specialized client for Rutgers University transit system.
    
    Filters routes and provides Rutgers-specific data structures.
    """

    RUTGERS_SYSTEM_ID = 1268

    def __init__(self):
        """
        Initialize the Rutgers client with excluded routes.
        """
        self.passiogo_client : PassioGOClient = PassioGOClient(system_id=self.RUTGERS_SYSTEM_ID)
        self.excluded_route_ids : set = {RutgersRouteIds.CAMDEN, RutgersRouteIds.ON1, RutgersRouteIds.ON2, 
                                         RutgersRouteIds.ALLCAMP, RutgersRouteIds.CCEXP, RutgersRouteIds.CAMPUS_CONNECT, 
                                         RutgersRouteIds.PENN_EXPR, RutgersRouteIds.PENN_LOCAL}

    def get_routes(self, as_dict : bool = True) -> dict[str, RutgersRoute] | list[RutgersRoute]:
        """
        Fetch Rutgers routes, excluding certain routes.
        
        Args:
            as_dict (bool): If True, return dict keyed by route ID; else list.
        
        Returns:
            dict[str, RutgersRoute] or list[RutgersRoute]: Routes data.
        """
        routes_dict = self.passiogo_client.get_routes()
        stops_response = self.passiogo_client.get_stops()
        stops_dict = stops_response.stops_dict
        route_points = stops_response.route_points
        stops_per_route = stops_response.routes
        rutgers_routes_dict = {}
        rutgers_routes_list = []

        for route_id, route in routes_dict.items():

            if route_id in self.excluded_route_ids:
                continue

            rutgers_route = RutgersRoute(
                id = route_id,
                name = route.name,
                short_name = route.shortName,
                color = route.color
            )

            rutgers_route.stops_list = []
            rutgers_route.stops_dict = {}

            if not stops_per_route and route_id not in stops_per_route:
                raise ValueError(f"No stops found for route ID: {route_id}")
            
            for stop_id_info in stops_per_route[route_id][2:]:
        
                if stop_id_info[1] not in stops_dict:
                    raise ValueError(f"Stop ID {stop_id_info[1]} not found in stops_dict")

                stop = stops_dict[stop_id_info[1]]

                rutgers_stop = RutgersStop(
                    id = stop_id_info[1],
                    route_id = route_id,
                    name = stop.name,
                    position_index = stop_id_info[0],
                    position_coord = Coordinate(latitude=stop.latitude, longitude=stop.longitude)
                )

                rutgers_route.stops_list.append(rutgers_stop)
                rutgers_route.stops_dict[rutgers_stop.id] = rutgers_stop

            rutgers_route.coords_list = [Coordinate(latitude=p['lat'], longitude=p['lng']) for p in route_points.get(route_id, [[]])[0]]

            rutgers_routes_dict[route_id] = rutgers_route
            rutgers_routes_list.append(rutgers_route)

        return rutgers_routes_dict if as_dict else rutgers_routes_list
    
    def get_buses(self) -> list[RutgersBus]:
        """
        Fetch current Rutgers buses, excluding certain routes.
        
        Returns:
            list[RutgersBus]: List of active buses.
        """
        buses = self.passiogo_client.get_buses()
        return [
            RutgersBus(
                id = str(bus.busId),
                route_id = bus.routeId,
                route_block_id = bus.routeBlockId,
                name = bus.bus,
                pax_load = bus.paxLoad,
                total_capacity = bus.totalCap,
                is_out_of_service = bus.outOfService,
                is_outdated = bus.outdated,
                heading_in_degrees = bus.calculatedCourse,
                speed_in_mph = bus.speed,
                position_coord = Coordinate(latitude=bus.latitude, longitude=bus.longitude)
            ) for bus in buses if bus.routeId not in self.excluded_route_ids
        ]
    
    def get_etas_for_stop(self, stop : RutgersStop):
        """
        Fetch ETAs for buses arriving at a specific stop.
        
        Args:
            stop (RutgersStop): The stop to get ETAs for.
        
        Returns:
            list[RutgersBus]: List of buses with ETA information.
        """
        etas = self.passiogo_client.get_eta([stop.id], stop.route_id, stop.position_index, as_dict=False)
        rutgers_buses = []
        for eta in etas:
            if eta.eta == 'no vehicles':
                continue
           
            pax_load = None
            if eta.paxLoadS:
                try:
                    pax_load = int(eta.paxLoadS.rstrip('%'))
                except ValueError:
                    pax_load = None
          
            position_coord = None
            if eta.busLatLng and len(eta.busLatLng) == 2:
                position_coord = Coordinate(latitude=float(eta.busLatLng[0]), longitude=float(eta.busLatLng[1]))
            
            eta_in_minutes = None
            if eta.etaR:
                try:
                    eta_in_minutes = int(eta.etaR)
                except (ValueError, TypeError):
                    eta_in_minutes = None
   
            rutgers_eta = RutgersETA(
                eta_description=eta.eta,
                eta_in_minutes=eta_in_minutes,
                eta_in_seconds=eta.secondsSpent,
                updated_seconds_ago=eta.updatedSecAgo
            )

            bus_id = eta.solidEta.busId if eta.solidEta and eta.solidEta.busId else eta.busId
            route_id = eta.solidEta.routeId if eta.solidEta and eta.solidEta.routeId else eta.routeId
            rutgers_bus = RutgersBus(
                id=str(bus_id) if bus_id else None,
                route_id=route_id,
                route_block_id=eta.routeBlockId,
                name=eta.busName,
                pax_load=pax_load,
                total_capacity=None,
                is_out_of_service=bool(eta.outOfService) if eta.outOfService is not None else None,
                is_outdated=bool(eta.outdated) if eta.outdated is not None else None,
                heading_in_degrees=None,
                speed_in_mph=eta.speed,
                position_coord=position_coord,
                eta=rutgers_eta
            )
            rutgers_buses.append(rutgers_bus)
        return rutgers_buses

    
if __name__ == "__main__":
    # Example usage: Fetch routes with stops and ETAs, output as JSON
    rutgers_client = RutgersPassioGOClient()
    routes = rutgers_client.get_routes(as_dict=False)
    data = []
    for route in routes:
        route_dict = route.to_dict()
        stops_data = []
        for stop in route.stops_list:
            stop_dict = stop.to_dict()
            buses = rutgers_client.get_etas_for_stop(stop)
            stop_dict['etas'] = [bus.to_dict() for bus in buses]
            stops_data.append(stop_dict)
        route_dict['stops_list'] = stops_data
        data.append(route_dict)
    print(json.dumps(data, indent=4))

    
