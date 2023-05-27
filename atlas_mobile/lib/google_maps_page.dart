import 'dart:async';
import 'dart:developer';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_maps_utils/google_maps_utils.dart';

const LatLng DEST_LOCATION = LatLng(41.1782, -8.6067);
const LatLng ISEP_ENTRANCE = LatLng(41.1782, -8.6067);
const LatLng BEntrance = LatLng(41.177828, -8.607819);
const LatLng LEntrance = LatLng(41.177780, -8.607905);
const LatLng GEntrance = LatLng(41.177513, -8.607921);
const LatLng HEntrance = LatLng(41.178034, -8.608426);
const LatLng IEntrance = LatLng(41.178131, -8.608211);
const LatLng JEntrance = LatLng(41.178644, -8.607465);
const LatLng CEntrance = LatLng(41.178607, -8.607186);
const LatLng DEntrance = LatLng(41.179197, -8.607116);
const LatLng AEntrance = LatLng(41.1785, -8.6090);
const LatLng FEntrance = LatLng(41.179055, -8.607857);

late Uint8List AIcon;
late Uint8List BIcon;
late Uint8List CIcon;
late Uint8List DIcon;
late Uint8List EIcon;
late Uint8List FIcon;
late Uint8List GIcon;
late Uint8List HIcon;
late Uint8List IIcon;
late Uint8List JIcon;

List<LatLng> BtoACoordinates = [];
List<LatLng> CtoACoordinates = [];
List<LatLng> DtoACoordinates = [];
List<LatLng> EtoACoordinates = [];
List<LatLng> FtoACoordinates = [];
List<LatLng> GtoACoordinates = [];
List<LatLng> HtoACoordinates = [];
List<LatLng> ItoACoordinates = [];
List<LatLng> JtoACoordinates = [];

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
  bool showingBuildingPath = false;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    loadCustomMarkerIcons();
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
          showMarker();
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
    if (showingBuildingPath) {
      return;
    }
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
                polylines: _polylines,
                markers: _markers,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);

                  getCurrentLocation();
                  showMarker();
                  //setPolylines();
                  updateLocation();
                },
              ));
  }

  Future<void> showMarker() async {
    _markers.clear();
    _markers.add(Marker(
      markerId: MarkerId("currentLocation"),
      position: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
      icon: BitmapDescriptor.defaultMarker,
    ));
    _markers.add(Marker(
      markerId: MarkerId("destination"),
      position: destinationLocation,
      icon: BitmapDescriptor.defaultMarkerWithHue(90),
    ));

    _markers.add(Marker(
        markerId: MarkerId("A"),
        position: AEntrance,
        icon: await BitmapDescriptor.fromBytes(AIcon)));
    _markers.add(Marker(
        markerId: MarkerId("B"),
        position: BEntrance,
        onTap: () {
          if (showingBuildingPath) {
            showingBuildingPath = false;
            _polylines.clear();
            setPolylines();
          } else {
            _polylines.clear();
            _polylines.add(Polyline(
                width: 10,
                polylineId: PolylineId('BPolyLine'),
                color: Colors.orange,
                points: BtoACoordinates));
            showingBuildingPath = true;
          }
        },
        icon: await BitmapDescriptor.fromBytes(BIcon)));
    _markers.add(Marker(
        markerId: MarkerId("C"),
        position: CEntrance,
        onTap: () {
          if (showingBuildingPath) {
            showingBuildingPath = false;
            _polylines.clear();
            setPolylines();
          } else {
            _polylines.clear();
            _polylines.add(Polyline(
                width: 10,
                polylineId: PolylineId('CPolyLine'),
                color: Colors.orange,
                points: CtoACoordinates));
            showingBuildingPath = true;
          }
        },
        icon: await BitmapDescriptor.fromBytes(CIcon)));
    _markers.add(Marker(
        markerId: MarkerId("D"),
        position: DEntrance,
        onTap: () {
          if (showingBuildingPath) {
            showingBuildingPath = false;
            _polylines.clear();
            setPolylines();
          } else {
            _polylines.clear();
            _polylines.add(Polyline(
                width: 10,
                polylineId: PolylineId('DPolyLine'),
                color: Colors.orange,
                points: DtoACoordinates));
            showingBuildingPath = true;
          }
        },
        icon: await BitmapDescriptor.fromBytes(DIcon)));
    _markers.add(Marker(
        markerId: MarkerId("F"),
        position: FEntrance,
        onTap: () {
          if (showingBuildingPath) {
            showingBuildingPath = false;
            _polylines.clear();
            setPolylines();
          } else {
            _polylines.clear();
            _polylines.add(Polyline(
                width: 10,
                polylineId: PolylineId('FPolyLine'),
                color: Colors.orange,
                points: FtoACoordinates));
            showingBuildingPath = true;
          }
        },
        icon: await BitmapDescriptor.fromBytes(FIcon)));
    _markers.add(Marker(
        markerId: MarkerId("G"),
        position: GEntrance,
        onTap: () {
          if (showingBuildingPath) {
            showingBuildingPath = false;
            _polylines.clear();
            setPolylines();
          } else {
            _polylines.clear();
            _polylines.add(Polyline(
                width: 10,
                polylineId: PolylineId('GPolyLine'),
                color: Colors.orange,
                points: GtoACoordinates));
            showingBuildingPath = true;
          }
        },
        icon: await BitmapDescriptor.fromBytes(GIcon)));
    _markers.add(Marker(
        markerId: MarkerId("H"),
        position: HEntrance,
        onTap: () {
          if (showingBuildingPath) {
            showingBuildingPath = false;
            _polylines.clear();
            setPolylines();
          } else {
            _polylines.clear();
            _polylines.add(Polyline(
                width: 10,
                polylineId: PolylineId('HPolyLine'),
                color: Colors.orange,
                points: HtoACoordinates));
            showingBuildingPath = true;
          }
        },
        icon: await BitmapDescriptor.fromBytes(HIcon)));
    _markers.add(Marker(
        markerId: MarkerId("I"),
        position: IEntrance,
        onTap: () {
          if (showingBuildingPath) {
            showingBuildingPath = false;
            _polylines.clear();
            setPolylines();
          } else {
            _polylines.clear();
            _polylines.add(Polyline(
                width: 10,
                polylineId: PolylineId('IPolyLine'),
                color: Colors.orange,
                points: ItoACoordinates));
            showingBuildingPath = true;
          }
        },
        icon: await BitmapDescriptor.fromBytes(IIcon)));
    _markers.add(Marker(
        markerId: MarkerId("J"),
        position: JEntrance,
        onTap: () {
          if (showingBuildingPath) {
            showingBuildingPath = false;
            _polylines.clear();
            setPolylines();
          } else {
            _polylines.clear();
            _polylines.add(Polyline(
                width: 10,
                polylineId: PolylineId('JPolyLine'),
                color: Colors.orange,
                points: JtoACoordinates));
            showingBuildingPath = true;
          }
        },
        icon: await BitmapDescriptor.fromBytes(JIcon)));
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  void setPolylines() async {
    if (showingBuildingPath) {
      return;
    }
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

      List<LatLng> testCoordinates = [];
      PolylineResult testresult =
          await polylinePoints.getRouteBetweenCoordinates(
              "AIzaSyB4OGOittahn-IB8c7l2LWfpOLPUMxgms8",
              PointLatLng(41.178131, -8.608211),
              PointLatLng(AEntrance.latitude, AEntrance.longitude),
              travelMode: TravelMode.walking);

      BtoACoordinates = [
        LatLng(41.17799, -8.6078),
        LatLng(41.17801, -8.60819),
        LatLng(41.17804, -8.60825),
        LatLng(41.17817, -8.60826),
        LatLng(41.17841, -8.60825),
        LatLng(41.17853, -8.60825),
        LatLng(41.17855, -8.60831),
        LatLng(41.17858, -8.60864),
        LatLng(41.1786, -8.6090),
        LatLng(41.1785, -8.6090),
      ];

      CtoACoordinates = [
        LatLng(41.178607, -8.607186),
        LatLng(41.178644, -8.607465),
        LatLng(41.1787, -8.6078),
        LatLng(41.1785, -8.6079),
        LatLng(41.17858, -8.60864),
        LatLng(41.1786, -8.6090),
        LatLng(41.1785, -8.6090),
      ];

      DtoACoordinates = [
        LatLng(41.179197, -8.607116),
        LatLng(41.1790, -8.6068),
        LatLng(41.178607, -8.607186),
        LatLng(41.178644, -8.607465),
        LatLng(41.1787, -8.6078),
        LatLng(41.1785, -8.6079),
        LatLng(41.17858, -8.60864),
        LatLng(41.1786, -8.6090),
        LatLng(41.1785, -8.6090),
      ];
      FtoACoordinates = [
        LatLng(41.179055, -8.607857),
        LatLng(41.1787, -8.6078),
        LatLng(41.1785, -8.6079),
        LatLng(41.17858, -8.60864),
        LatLng(41.1786, -8.6090),
        LatLng(41.1785, -8.6090),
      ];

      GtoACoordinates = [
        LatLng(41.1775, -8.6079),
        LatLng(41.17799, -8.6078),
        LatLng(41.17801, -8.60819),
        LatLng(41.17804, -8.60825),
        LatLng(41.17817, -8.60826),
        LatLng(41.17841, -8.60825),
        LatLng(41.17853, -8.60825),
        LatLng(41.17855, -8.60831),
        LatLng(41.17858, -8.60864),
        LatLng(41.1786, -8.6090),
        LatLng(41.1785, -8.6090),
      ];
      HtoACoordinates = [
        LatLng(41.178034, -8.608426),
        LatLng(41.17806, -8.60826),
        LatLng(41.17806, -8.60826),
        LatLng(41.17817, -8.60826),
        LatLng(41.17841, -8.60825),
        LatLng(41.17853, -8.60825),
        LatLng(41.17855, -8.60831),
        LatLng(41.17858, -8.60864),
        LatLng(41.1786, -8.6090),
        LatLng(41.1785, -8.6090),
      ];

      ItoACoordinates = [
        LatLng(41.178131, -8.608211),
        LatLng(41.17813, -8.60826),
        LatLng(41.17825, -8.60827),
        LatLng(41.17847, -8.60824),
        LatLng(41.17853, -8.60826),
        LatLng(41.17856, -8.6084),
        LatLng(41.17858, -8.60864),
        LatLng(41.1786, -8.6090),
        LatLng(41.1785, -8.6090),
      ];

      List<LatLng> JtoACoordinates = [
        LatLng(41.178644, -8.607465),
        LatLng(41.1787, -8.6078),
        LatLng(41.1785, -8.6079),
        LatLng(41.17858, -8.60864),
        LatLng(41.1786, -8.6090),
        LatLng(41.1785, -8.6090),
      ];

      setState(() {
        _polylines.add(Polyline(
            width: 10,
            polylineId: PolylineId('polyLine'),
            color: Color(0xFF08A5CB),
            points: polylineCoordinates));
      });
    }
  }

  void loadCustomMarkerIcons() async {
    AIcon = await getBytesFromAsset('assets/images/A.png', 50);
    BIcon = await getBytesFromAsset('assets/images/B.png', 50);
    CIcon = await getBytesFromAsset('assets/images/C.png', 50);
    DIcon = await getBytesFromAsset('assets/images/D.png', 50);
    EIcon = await getBytesFromAsset('assets/images/E.png', 50);
    FIcon = await getBytesFromAsset('assets/images/F.png', 50);
    GIcon = await getBytesFromAsset('assets/images/G.png', 50);
    HIcon = await getBytesFromAsset('assets/images/H.png', 50);
    IIcon = await getBytesFromAsset('assets/images/I.png', 50);
    JIcon = await getBytesFromAsset('assets/images/J.png', 50);
  }
}
