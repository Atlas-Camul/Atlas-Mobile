import 'dart:async';
import 'dart:developer';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_maps_utils/google_maps_utils.dart';

const LatLng DEST_LOCATION = LatLng(41.1782, -8.6067);

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

  List<Point> isepPolygonPoints = [
    Point(41.179420, -8.609310),
    Point(41.179404, -8.605831),
    Point(41.177126, -8.607913),
    Point(41.177433, -8.609030),
  ];

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

    setState(() {
      currentLocation = location;
      isLoading = false;
    });

    //ISEP CHECK !!!!
    if (!PolyUtils.containsLocationPoly(
        Point(location.latitude, location.longitude), isepPolygonPoints)) {
      setPolylines();
    } else {
      print("already in isep");
    }
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
            CameraPosition(target: LatLng(lat, long), zoom: 19)));
        if (!PolyUtils.containsLocationPoly(
            Point(location.latitude, location.longitude), isepPolygonPoints)) {
          updatePolylines(location);
        } else {
          print("already in isep");
          polylineCoordinates.clear();
        }
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
                    CameraPosition(target: currentLocation, zoom: 19),
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
                  getCurrentLocation();
                  //setPolylines();
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
