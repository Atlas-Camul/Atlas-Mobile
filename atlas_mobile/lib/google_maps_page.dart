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
const LatLng AEntrance = LatLng(41.178547, -8.608646);
const LatLng FEntrance = LatLng(41.179055, -8.607857);

late final Uint8List AIcon;
late final Uint8List BIcon;
late final Uint8List CIcon;
late final Uint8List DIcon;
late final Uint8List EIcon;
late final Uint8List FIcon;
late final Uint8List GIcon;
late final Uint8List HIcon;
late final Uint8List IIcon;
late final Uint8List JIcon;

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

                  showMarker();
                  getCurrentLocation();
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
        icon: await BitmapDescriptor.fromBytes(BIcon)));
    _markers.add(Marker(
        markerId: MarkerId("C"),
        position: CEntrance,
        icon: await BitmapDescriptor.fromBytes(CIcon)));
    _markers.add(Marker(
        markerId: MarkerId("D"),
        position: DEntrance,
        icon: await BitmapDescriptor.fromBytes(DIcon)));
    _markers.add(Marker(
        markerId: MarkerId("F"),
        position: FEntrance,
        icon: await BitmapDescriptor.fromBytes(FIcon)));
    _markers.add(Marker(
        markerId: MarkerId("G"),
        position: GEntrance,
        icon: await BitmapDescriptor.fromBytes(GIcon)));
    _markers.add(Marker(
        markerId: MarkerId("H"),
        position: HEntrance,
        icon: await BitmapDescriptor.fromBytes(HIcon)));
    _markers.add(Marker(
        markerId: MarkerId("I"),
        position: IEntrance,
        icon: await BitmapDescriptor.fromBytes(IIcon)));
    _markers.add(Marker(
        markerId: MarkerId("J"),
        position: JEntrance,
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

      if (testresult.status == 'OK') {
        testCoordinates.clear();
        testresult.points.forEach((PointLatLng point) {
          testCoordinates.add(LatLng(point.latitude, point.longitude));
          print(point.latitude.toString() + ',' + point.longitude.toString());
        });

        List<LatLng> BtoACoordinates = [];
        BtoACoordinates = [
          LatLng(41.17799, -8.6078),
          LatLng(41.17801, -8.60819),
          LatLng(41.17804, -8.60825),
          LatLng(41.17817, -8.60826),
          LatLng(41.17841, -8.60825),
          LatLng(41.17853, -8.60825),
          LatLng(41.17855, -8.60831),
          LatLng(41.17858, -8.60864)
        ];

        List<LatLng> CtoACoordinates = [];
        CtoACoordinates = [
          LatLng(41.1786, -8.6072),
          LatLng(41.17851, -8.60708),
          LatLng(41.17843, -8.60717),
          LatLng(41.17835, -8.60722),
          LatLng(41.17829, -8.60724),
          LatLng(41.17789, -8.60728),
          LatLng(41.17776, -8.60737),
          LatLng(41.17771, -8.60743),
          LatLng(41.1777, -8.60749),
          LatLng(41.1778, -8.60751),
          LatLng(41.17788, -8.60751),
          LatLng(41.17791, -8.60753),
          LatLng(41.17795, -8.60759),
          LatLng(41.17799, -8.60789),
          LatLng(41.17801, -8.60821),
          LatLng(41.17803, -8.60825),
          LatLng(41.17807, -8.60826),
          LatLng(41.17825, -8.60827),
          LatLng(41.17847, -8.60824),
          LatLng(41.17853, -8.60826),
          LatLng(41.17856, -8.6084),
          LatLng(41.17858, -8.60864),
        ];

        List<LatLng> GtoACoordinates = [
          LatLng(41.1775, -8.6079),
          LatLng(41.17799, -8.6078),
          LatLng(41.17801, -8.60819),
          LatLng(41.17804, -8.60825),
          LatLng(41.17817, -8.60826),
          LatLng(41.17841, -8.60825),
          LatLng(41.17853, -8.60825),
          LatLng(41.17855, -8.60831),
          LatLng(41.17858, -8.60864)
        ];
        List<LatLng> HtoACoordinates = [
          LatLng(41.178034, -8.608426),
          LatLng(41.17806, -8.60826),
          LatLng(41.17806, -8.60826),
          LatLng(41.17817, -8.60826),
          LatLng(41.17841, -8.60825),
          LatLng(41.17853, -8.60825),
          LatLng(41.17855, -8.60831),
          LatLng(41.17858, -8.60864),
        ];

        List<LatLng> ItoACoordinates = [
          LatLng(41.178131, -8.608211),
          LatLng(41.17813, -8.60826),
          LatLng(41.17825, -8.60827),
          LatLng(41.17847, -8.60824),
          LatLng(41.17853, -8.60826),
          LatLng(41.17856, -8.6084),
          LatLng(41.17858, -8.60864),
        ];

        List<LatLng> JtoACoordinates = [
          LatLng(41.178644, -8.607465),
          LatLng(41.1787, -8.6077),
          LatLng(41.17852, -8.60796),
          LatLng(41.17865, -8.60813),
          LatLng(41.17869, -8.60823),
          LatLng(41.17875, -8.60871),
          LatLng(41.17864, -8.60871),
          LatLng(41.1786, -8.60869),
          LatLng(41.17858, -8.60865),
          LatLng(41.17858, -8.60864),
        ];

        _polylines.add(Polyline(
            polylineId: PolylineId("BtoA"),
            width: 10,
            color: Colors.orange,
            points: ItoACoordinates));

        setState(() {
          _polylines.add(Polyline(
              width: 10,
              polylineId: PolylineId('polyLine'),
              color: Color(0xFF08A5CB),
              points: polylineCoordinates));
        });
      }
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
