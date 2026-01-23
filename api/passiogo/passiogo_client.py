import requests 
from enum import Enum
import time

"""
PassioGO Client Module

This module provides a client for interacting with the PassioGO transit API.
It includes classes for representing routes, stops, buses, and ETAs, as well as
a main client class for making API requests.

Classes:
    - HTTPRequestType: Enum for HTTP request types.
    - Route: Represents a transit route.
    - Stop: Represents a transit stop.
    - Center: Represents map center data.
    - GetStopsResponse: Response object for stops data.
    - Bus: Represents a transit bus.
    - SolidEta: Represents solid ETA data.
    - ETA: Represents estimated time of arrival.
    - PassioGOClient: Main client for API interactions.
"""

class HTTPRequestType(Enum):
    GET = "GET"
    POST = "POST"
    

class Route:
    """
    Represents a transit route with various attributes like name, color, and schedule info.
    """
    def __init__(
        self,
        name: str = None,
        shortName: str = None,
        color: str = None,
        userId: str = None,
        myid: str = None,
        mapApp: str = None,
        archive: str = None,
        goPrefixRouteName: str = None,
        goShowSchedule: str = None,
        outdated: str = None,
        id: str = None,
        distance: int = None,
        latitude: str = None,
        longitude: str = None,
        timezone: str = None,
        fullname: str = None,
        nameOrig: str = None,
        groupId: int = None,
        groupColor: str = None,
        serviceTime: str = None,
        serviceTimeShort: str = None,
        **kwargs,
    ):
        self.name = name
        self.shortName = shortName
        self.color = color
        self.userId = userId
        self.myid = myid
        self.mapApp = mapApp
        self.archive = archive
        self.goPrefixRouteName = goPrefixRouteName
        self.goShowSchedule = goShowSchedule
        self.outdated = outdated
        self.id = id
        self.distance = distance
        self.latitude = latitude
        self.longitude = longitude
        self.timezone = timezone
        self.fullname = fullname
        self.nameOrig = nameOrig
        self.groupId = groupId
        self.groupColor = groupColor
        self.serviceTime = serviceTime
        self.serviceTimeShort = serviceTimeShort

        for key, value in kwargs.items():
            setattr(self, key, value)

class Stop:
    """
    Represents a transit stop with location, name, and route information.
    """
    def __init__(
        self,
        routeId: str = None,
        stopId: str = None,
        position: str = None,
        name: str = None,
        latitude: float = None,
        longitude: float = None,
        id: str = None,
        userId: str = None,
        radius: int = None,
        routeName: str = None,
        routeShortname: str = None,
        routeGroupId: int = None,
        **kwargs,
    ):
        self.routeId = routeId
        self.stopId = stopId
        self.position = position
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.id = id
        self.userId = userId
        self.radius = radius
        self.routeName = routeName
        self.routeShortname = routeShortname
        self.routeGroupId = routeGroupId

        for key, value in kwargs.items():
            setattr(self, key, value)
    
class Center:
    """
    Represents the center point and bounds of a map view.
    """
    def __init__(
        self,
        latitude: str = None,
        longitude: str = None,
        latitudeMin: str = None,
        longitudeMin: str = None,
        latitudeMax: str = None,
        longitudeMax: str = None,
        amount: str = None,
        d: float = None,
        amountYard: str = None,
        hub: list = None,
        hubHints: list = None,
        hubOld: list = None,
        t: float = None,
        **kwargs
    ):
        self.latitude = latitude
        self.longitude = longitude
        self.latitudeMin = latitudeMin
        self.longitudeMin = longitudeMin
        self.latitudeMax = latitudeMax
        self.longitudeMax = longitudeMax
        self.amount = amount
        self.d = d
        self.amountYard = amountYard
        self.hub = hub
        self.hubHints = hubHints
        self.hubOld = hubOld
        self.t = t
        for key, value in kwargs.items():
            setattr(self, key, value)

class GetStopsResponse:
    """
    Response object containing stops data, routes, and map information.
    """
    def __init__(
        self,
        stops_list: list[Stop] = None,
        stops_dict : dict[str, Stop] = None,
        routes: dict = None,
        route_points: dict = None,
        group_routes: bool = None,
        route_short_names: dict = None,
        route_schedules: dict = None,
        routes_rr: list = None,
        excluded_routes_id: list = None,
        stops_rr: list = None,
        center: Center = None,
    ):
        self.stops_list = stops_list
        self.stops_dict = stops_dict
        self.routes = routes
        self.route_points = route_points
        self.group_routes = group_routes
        self.route_short_names = route_short_names
        self.route_schedules = route_schedules
        self.routes_rr = routes_rr
        self.excluded_routes_id = excluded_routes_id
        self.stops_rr = stops_rr
        self.center = center

class Bus:
    """
    Represents a transit bus with location, status, and capacity information.
    """
    def __init__(
        self,
        deviceId: int = None,
        created: str = None,
        createdTime: str = None,
        paxLoad: int = None,
        bus: str = None,
        busId: int = None,
        userId: str = None,
        routeBlockId: str = None,
        latitude: str = None,
        longitude: str = None,
        calculatedCourse: float = None,
        outOfService: int = None,
        more: str = None,
        speed: float = None,
        totalCap: int = None,
        color: str = None,
        busName: str = None,
        busType: str = None,
        routeId: str = None,
        route: str = None,
        outdated: int = None,
        snapDistance: float = None,
        **kwargs
    ):
        self.deviceId = deviceId
        self.created = created
        self.createdTime = createdTime
        self.paxLoad = paxLoad
        self.bus = bus
        self.busId = busId
        self.userId = userId
        self.routeBlockId = routeBlockId
        self.latitude = latitude
        self.longitude = longitude
        self.calculatedCourse = calculatedCourse
        self.outOfService = outOfService
        self.more = more
        self.speed = speed
        self.totalCap = totalCap
        self.color = color
        self.busName = busName
        self.busType = busType
        self.routeId = routeId
        self.route = route
        self.outdated = outdated
        self.snapDistance = snapDistance

        for key, value in kwargs.items():
            setattr(self, key, value)
    
class SolidEta:
    """
    Represents detailed ETA information with scheduled times.
    """
    def __init__(
        self,
        id: str = None,
        busId: str = None,
        updated: str = None,
        updatedUtc: str = None,
        arrival: str = None,
        arrivalUtc: str = None,
        scheduledArrival: str = None,
        scheduledArrivalUtc: str = None,
        scheduledDeparture: str = None,
        scheduledDepartureUtc: str = None,
        stopId: str = None,
        routeId: str = None,
        routeStopId: str = None,
        tripId: str = None,
        deviceId: str = None,
        etaVersionId: str = None,
        routeGroupId: str = None,
        tripIndex: str = None,
        tripStart: str = None,
        duration: int = None,
        arrivalActual: str = None,
        arrivalActualUtc: str = None,
        **kwargs
    ):
        self.id = id
        self.busId = busId
        self.updated = updated
        self.updatedUtc = updatedUtc
        self.arrival = arrival
        self.arrivalUtc = arrivalUtc
        self.scheduledArrival = scheduledArrival
        self.scheduledArrivalUtc = scheduledArrivalUtc
        self.scheduledDeparture = scheduledDeparture
        self.scheduledDepartureUtc = scheduledDepartureUtc
        self.stopId = stopId
        self.routeId = routeId
        self.routeStopId = routeStopId
        self.tripId = tripId
        self.deviceId = deviceId
        self.etaVersionId = etaVersionId
        self.routeGroupId = routeGroupId
        self.tripIndex = tripIndex
        self.tripStart = tripStart
        self.duration = duration
        self.arrivalActual = arrivalActual
        self.arrivalActualUtc = arrivalActualUtc

        for key, value in kwargs.items():
            setattr(self, key, value)

class ETA:
    """
    Represents estimated time of arrival for a bus at a stop.
    """
    def __init__(
        self,
        eta: str = None,
        etaR: str = None,
        secondsSpent: int = None,
        routeId: str = None,
        busName: str = None,
        goShowSchedule: str = None,
        scheduleTimes: list = None,
        outdated: int = None,
        reason: str = None,
        order: int = None,
        outOfService: bool = None,
        solid: int = None,
        updatedSecAgo: int = None,
        paxLoadS: str = None,
        driver: str = None,
        scheduleNotEmpty: str = None,
        solidEta: SolidEta = None,
        OOS: int = None,
        distance: float = None,
        speed: float = None,
        routeBlockId: str = None,
        actualRouteBlockId: str = None,
        arrived: str = None,
        color: str = None,
        bg: str = None,
        dwell: str = None,
        stopsAmount: int = None,
        arrivalTimestamp: int = None,
        etaUtc: int = None,
        error: str = None,
        serviceTime: str = None,
        looping: str = None,
        busId: int = None,
        tripId: str = None,
        deviceId: int = None,
        created: str = None,
        routePointPosition: int = None,
        routeStopPosition: int = None,
        stopRoutePointPosition: int = None,
        timezoneOffset: int = None,
        busLatLng: list = None,
        busProjectionLatlng: dict = None,
        busProjectionError: float = None,
        stopId: str = None,
        theStop: dict = None,
        **kwargs
    ):
        self.eta = eta
        self.etaR = etaR
        self.secondsSpent = secondsSpent
        self.routeId = routeId
        self.busName = busName
        self.goShowSchedule = goShowSchedule
        self.scheduleTimes = scheduleTimes
        self.outdated = outdated
        self.reason = reason
        self.order = order
        self.outOfService = outOfService
        self.solid = solid
        self.updatedSecAgo = updatedSecAgo
        self.paxLoadS = paxLoadS
        self.driver = driver
        self.scheduleNotEmpty = scheduleNotEmpty
        self.solidEta = solidEta
        self.OOS = OOS
        self.distance = distance
        self.speed = speed
        self.routeBlockId = routeBlockId
        self.actualRouteBlockId = actualRouteBlockId
        self.arrived = arrived
        self.color = color
        self.bg = bg
        self.dwell = dwell
        self.stopsAmount = stopsAmount
        self.arrivalTimestamp = arrivalTimestamp
        self.etaUtc = etaUtc
        self.error = error
        self.serviceTime = serviceTime
        self.looping = looping
        self.busId = busId
        self.tripId = tripId
        self.deviceId = deviceId
        self.created = created
        self.routePointPosition = routePointPosition
        self.routeStopPosition = routeStopPosition
        self.stopRoutePointPosition = stopRoutePointPosition
        self.timezoneOffset = timezoneOffset
        self.busLatLng = busLatLng
        self.busProjectionLatlng = busProjectionLatlng
        self.busProjectionError = busProjectionError
        self.stopId = stopId
        self.theStop = theStop

        for key, value in kwargs.items():
            setattr(self, key, value)

class PassioGOClient:
    """
    Main client for interacting with the PassioGO API.
    
    Provides methods to fetch routes, stops, buses, and ETAs.
    """
    
    BASE_URL = "https://passiogo.com/mapGetData.php?"
    
    def __init__(self, system_id : int):
        """
        Initialize the client with a system ID.
        
        Args:
            system_id (int): The transit system identifier.
        """
        self.system_id = system_id

    def  _send_api_request(self, url : str, request_type : HTTPRequestType, body : dict = None):
        """
        Send an API request to the PassioGO server.
        
        Args:
            url (str): The API endpoint URL.
            request_type (HTTPRequestType): GET or POST.
            body (dict, optional): Request parameters or data.
        
        Returns:
            dict: The JSON response from the API.
        
        Raises:
            ValueError: If the response is invalid or contains an error.
        """
        if request_type == HTTPRequestType.GET:
            response = requests.get(url, params=body)
        else:
            response = requests.post(url, json=body)
        
        response.raise_for_status()

        try:
            result = response.json()
        except Exception as e:
            raise ValueError("Failed to parse JSON response") from e
        
        if 'error' in result and result['error']:
            raise ValueError(f"API Error: {response}")
        
        return result 
    
    def get_routes(self, as_dict : bool = True) -> dict[str, Route] | list[Route]:
        """
        Fetch all routes for the system.
        
        Args:
            as_dict (bool): If True, return a dict keyed by route ID; else a list.
        
        Returns:
            dict[str, Route] or list[Route]: The routes data.
        """
        try:
            url = self.BASE_URL + "getRoutes=1"
            body = {"systemSelected0": str(self.system_id), "amount": 1}
            response = self._send_api_request(url, HTTPRequestType.POST, body)
            
            if not isinstance(response, list):
                raise ValueError(f"Expected list of routes, got {type(response)}")
            
            routes_dict = {}
            routes_list = []

            for route_data in response:
                if not isinstance(route_data, dict):
                    raise ValueError(f"Expected dict for route data, got {type(route_data)}")
                try:
                    route = Route(**route_data)
                    routes_dict[route.myid] = route
                    routes_list.append(route)
                except TypeError as e:
                    raise ValueError(f"Invalid route data: {route_data}") from e
            
            return routes_dict if as_dict else routes_list
        
        except Exception as e:
            raise ValueError(f"Failed to get routes: {str(e)}") from e
        
    def get_stops(self) -> GetStopsResponse:
        """
        Fetch stops data including routes and map information.
        
        Returns:
            GetStopsResponse: Object containing stops and related data.
        """
        try:
            url = self.BASE_URL + "getStops=2"
            body = {"s0": str(self.system_id), "sA": 1}
            response = self._send_api_request(url, HTTPRequestType.POST, body)
            
            if not isinstance(response, dict):
                raise ValueError(f"Expected dict response, got {type(response)}")
            
            stops_data = response.get('stops', {})
            if not isinstance(stops_data, dict):
                raise ValueError(f"Expected dict for stops data, got {type(stops_data)}")
            
            stops_list = []
            stops_dict = {}
            for stop_key, stop_data in stops_data.items():
                if not isinstance(stop_data, dict):
                    raise ValueError(f"Expected dict for stop data, got {type(stop_data)}")
                try:
                    stop = Stop(**stop_data)
                    stops_dict[stop_key[2:]] = stop
                    stops_list.append(stop)
                except TypeError as e:
                    raise ValueError(f"Invalid stop data: {stop_data}") from e
           
            center_data = response.get('center', {})
            center = Center(**center_data) if center_data else None
            
            routes = response.get('routes', {})
            route_points = response.get('routePoints', {})
            group_routes = response.get('groupRoutes', False)
            route_short_names = response.get('routeShortNames', {})
            route_schedules = response.get('routeSchedules', {})
            routes_rr = response.get('routesRR', [])
            excluded_routes_id = response.get('excludedRoutesID', [])
            stops_rr = response.get('stopsRR', [])
            
            return GetStopsResponse(
                stops_list=stops_list,
                stops_dict=stops_dict,
                routes=routes,
                route_points=route_points,
                group_routes=group_routes,
                route_short_names=route_short_names,
                route_schedules=route_schedules,
                routes_rr=routes_rr,
                excluded_routes_id=excluded_routes_id,
                stops_rr=stops_rr,
                center=center,
            )
        
        except Exception as e:
            raise ValueError(f"Failed to get stops: {str(e)}") from e
        
    def get_buses(self) -> list[Bus]:
        """
        Fetch current bus locations and status.
        
        Returns:
            list[Bus]: List of active buses.
        """
        try:
            url = self.BASE_URL + "getBuses=1&speed=1"
            body = {"s0": str(self.system_id), "sA": 1}
            response = self._send_api_request(url, HTTPRequestType.POST, body)
            
            if not isinstance(response, dict) or 'buses' not in response:
                raise ValueError(f"Expected dict with 'buses' key, got {type(response)}")
            
            buses_data = response['buses']
            if not isinstance(buses_data, dict):
                raise ValueError(f"Expected dict for buses data, got {type(buses_data)}")
            
            buses = []
            for device_id, bus_list in buses_data.items():
                if not isinstance(bus_list, list):
                    raise ValueError(f"Expected list for bus data, got {type(bus_list)}")
                for bus_data in bus_list:
                    if not isinstance(bus_data, dict):
                        raise ValueError(f"Expected dict for bus data, got {type(bus_data)}")
                    try:
                        bus = Bus(**bus_data)
                        buses.append(bus)
                    except TypeError as e:
                        raise ValueError(f"Invalid bus data: {bus_data}") from e
            
            return buses
        except Exception as e:
            raise ValueError(f"Failed to get buses: {str(e)}") from e
        
    def get_eta(self, stop_ids : list[str], route_id : str, position : int, as_dict : bool = True) -> dict[str, list[ETA]] | list[ETA]:
        """
        Fetch estimated times of arrival for buses at specified stops.
        
        Args:
            stop_ids (list[str]): List of stop IDs.
            route_id (str): The route ID.
            position (int): Position on the route.
            as_dict (bool): If True, return dict keyed by stop ID; else a flat list.
        
        Returns:
            dict[str, list[ETA]] or list[ETA]: The ETA data.
        """
        try:
            url = self.BASE_URL + "eta=3"
            body = {
                "stopIds": ",".join(stop_ids),
                "routeId" : route_id,
                "position" : str(position),
                "userId": str(self.system_id)
            }
            response = self._send_api_request(url, HTTPRequestType.GET, body)
            
            if not isinstance(response, dict) or 'ETAs' not in response:
                raise ValueError(f"Expected dict with 'ETAs' key, got {type(response)}")
            
            etas_data = response['ETAs']
            if not isinstance(etas_data, dict):
                raise ValueError(f"Expected dict for ETAs data, got {type(etas_data)}")
            
            etas_dict = {}
            etas_list = []
            for stop_key, eta_list in etas_data.items():
                if not isinstance(eta_list, list):
                    raise ValueError(f"Expected list for ETA data, got {type(eta_list)}")
                parsed_etas = []
                for eta_data in eta_list:
                    if not isinstance(eta_data, dict):
                        raise ValueError(f"Expected dict for ETA data, got {type(eta_data)}")
             
                    solid_eta_data = eta_data.get('solidEta')
                    solid_eta = SolidEta(**solid_eta_data) if solid_eta_data else None
                    eta_data['solidEta'] = solid_eta
                    try:
                        eta = ETA(**eta_data)
                        parsed_etas.append(eta)
                    except TypeError as e:
                        raise ValueError(f"Invalid ETA data: {eta_data}") from e
                etas_dict[stop_key] = parsed_etas
                etas_list.extend(parsed_etas)

            return etas_dict if as_dict else etas_list
        except Exception as e:
            raise ValueError(f"Failed to get ETAs: {str(e)}") from e
        
if __name__ == "__main__":
    # Example usage of the PassioGOClient
    client = PassioGOClient(1268)
    routes = client.get_routes(as_dict=False)
    stops_response = client.get_stops()
    buses = client.get_buses()
    etas = client.get_eta(["10052"], "55368", 2)
  
    for stop_id, eta_list in etas.items():
        print(f"Stop ID: {stop_id} - {len(eta_list)} ETAs")
        for eta in eta_list:
            print(f"  ETA: {eta.__dict__}")
            if eta.solidEta:
                print(f"    Solid ETA: {eta.solidEta.__dict__}")




