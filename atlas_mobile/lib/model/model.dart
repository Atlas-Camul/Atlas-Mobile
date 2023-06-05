import 'package:google_maps_flutter/google_maps_flutter.dart';

class Model {
  LatLng destLocation = const LatLng(41.1782, -8.6067);
  LatLng currentLocation = LatLng(41.1782, -8.6067);
  LatLng entranceB = LatLng(41.177828, -8.607819);
  LatLng entranceC = LatLng(41.177780, -8.607905);
  // Define other entrance locations

  List<LatLng> bToACoordinates = [];
  List<LatLng> cToACoordinates = [];
  // Define other coordinate lists

  List<Marker> beaconMarkers = [];
}
