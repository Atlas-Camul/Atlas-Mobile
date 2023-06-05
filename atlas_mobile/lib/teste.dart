import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'package:atlas_mobile/controllers/beacon_controller.dart';

class Teste extends StatefulWidget {
  @override
  _TesteState createState() => _TesteState();
}

class _TesteState extends State<Teste> {
  late GoogleMapController _mapController;
  

   List<Marker> _markers = [];
  FlutterBluePlus _flutterBlue = FlutterBluePlus.instance;
  bool _isScanning = false;

  BeaconController _beaconController = BeaconController();

  @override
  void initState() {
    super.initState();
    checkPermissions();
   
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> checkPermissions() async {
    var status = await Permission.location.status;
    if (status != PermissionStatus.granted) {
      await Permission.location.request();
    }
    startScan();
  }

  void startScan() {
    if (_isScanning) {
      return;
    }
    _isScanning = true;
    _markers.clear(); // Reset the markers before starting a new scan
    _flutterBlue.scan(timeout: Duration(seconds: 5)).listen((scanResult) async {
      if (scanResult!=null){


        print(scanResult.device);
      }
     
      final marker = await _beaconController.createMarkerFromBeacon(scanResult);
       
      
      if (marker != null) {
        print(marker);
        
        setState(() {

          

          _markers.add(marker);
          print(_markers);
        });
      }
    }).onDone(() {
      _isScanning = false;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teste'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: LatLng(0, 0), // Set the initial map position
          zoom: 10,
        ),
        markers: _markers.toSet(),
      ),
    );
  }
}


