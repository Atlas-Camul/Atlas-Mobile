import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';

const LatLng DEST_LOCATION = LatLng(41.207001, -8.285650);

class GoogleMapsPage extends StatefulWidget {
  const GoogleMapsPage({Key? key}) : super(key: key);

  @override
  State<GoogleMapsPage> createState() => _GoogleMapsPageState();
}

class _GoogleMapsPageState extends State<GoogleMapsPage> {
  Completer<GoogleMapController> _controller = Completer();

  Set<Marker> _markers = Set<Marker>();
  late LatLng currentLocation;
  late LatLng destinationLocation = DEST_LOCATION;

  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  late PolylinePoints polylinePoints;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    polylinePoints = PolylinePoints();
  }

  void getCurrentLocation() async {
    //GET PERMISSION
    geolocator.LocationPermission permission;
    permission = await geolocator.Geolocator.requestPermission();

    geolocator.Position position =
        await geolocator.Geolocator.getCurrentPosition(
            desiredAccuracy: geolocator.LocationAccuracy.high);
    double lat = position.latitude!;
    double long = position.longitude!;

    LatLng location = LatLng(lat, long);

    print(lat.toString());

    setState(() {
      currentLocation = location;
      isLoading = false;
    });
  }

  void updateLocation() async {
    GoogleMapController googleMapController = await _controller.future;

    final geolocator.LocationSettings locationSettings =
        geolocator.LocationSettings(
            accuracy: geolocator.LocationAccuracy.high, distanceFilter: 0);

    StreamSubscription<geolocator.Position> positionStream =
        geolocator.Geolocator.getPositionStream(
                locationSettings: locationSettings)
            .listen((geolocator.Position position) {
      double lat = position.latitude!;
      double long = position.longitude!;

      LatLng location = LatLng(lat, long);

      //IF LOCATION CHANGED, MOVE CAMERA
      if (currentLocation.latitude != lat ||
          currentLocation.longitude != long) {
        googleMapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(target: LatLng(lat, long), zoom: 13)));
        updatePolylines(location);
      }

      setState(() {
        currentLocation = location;
      });
    });
  }

  void updatePolylines(LatLng location) async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        "AIzaSyB4OGOittahn-IB8c7l2LWfpOLPUMxgms8",
        PointLatLng(location.latitude, location.longitude),
        PointLatLng(
            destinationLocation.latitude, destinationLocation.longitude));

    if (result.status == 'OK') {
      polylineCoordinates.clear();
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : GoogleMap(
                initialCameraPosition:
                    CameraPosition(target: currentLocation, zoom: 13),
                polylines: {
                  Polyline(
                      width: 10,
                      polylineId: PolylineId('polyLine'),
                      color: Color(0xFF08A5CB),
                      points: polylineCoordinates)
                },
                markers: {
                  Marker(
                    markerId: MarkerId("currentLocation"),
                    position: LatLng(currentLocation!.latitude!,
                        currentLocation!.longitude!),
                    icon: BitmapDescriptor.defaultMarker,
                  ),
                  Marker(
                    markerId: MarkerId("destination"),
                    position: destinationLocation,
                    icon: BitmapDescriptor.defaultMarkerWithHue(90),
                  )
                },
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);

                  //showMarker();
                  setPolylines();
                  updateLocation();
                },
              ));
  }

  void setPolylines() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        "AIzaSyB4OGOittahn-IB8c7l2LWfpOLPUMxgms8",
        PointLatLng(currentLocation.latitude, currentLocation.longitude),
        PointLatLng(
            destinationLocation.latitude, destinationLocation.longitude));

    if (result.status == 'OK') {
      polylineCoordinates.clear();
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });

      setState(() {
        // _polylines.add(Polyline(
        //     width: 10,
        //     polylineId: PolylineId('polyLine'),
        //     color: Color(0xFF08A5CB),
        //     points: polylineCoordinates));
      });
    }
  }
}
