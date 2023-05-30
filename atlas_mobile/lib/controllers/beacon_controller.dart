import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mysql1/mysql1.dart';
import 'package:atlas_mobile/db/db_settings.dart';
import 'package:atlas_mobile/model/beacon_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BeaconController {
  FlutterBluePlus _flutterBlue = FlutterBluePlus.instance;
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;

  List<ScanResult> get scanResults => List.from(_scanResults);
  bool get isScanning => _isScanning;

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
    _scanResults.clear(); // Reset the list before starting a new scan
    _flutterBlue.scan(timeout: Duration(seconds: 5)).listen((scanResult) {
      _scanResults.add(scanResult);
    }).onDone(() {
      _isScanning = false;
    });
  }

  Future<Marker> createMarkerFromBeacon(ScanResult scanResult) async {
    // Establish a connection with the beacon
    var device = scanResult.device;
    await device.connect();

    // Query the database for information based on the beacon's data
    var macAddress = device.id.toString();
    var databaseResult = await yourDatabaseQueryFunction(macAddress);
    var latitude = databaseResult.first['latitude'];
    var longitude = databaseResult.first['longitude'];

    var beacon = Beacon(
       macAddress=macAddress,
       latitude=latitude,
    longitude=longitude,
    );

    // Disconnect from the beacon
    await device.disconnect();

    // Create a map marker
    var marker = Marker(
      markerId: MarkerId(macAddress),
      position: LatLng(double.parse(databaseResult.first[latitude]), double.parse(databaseResult.first[longitude])),
      infoWindow: InfoWindow(title: macAddress),
    );

    return marker;
  }

  Future<Results> yourDatabaseQueryFunction(String macAddress) async {
    // Connect to the database
    final conn = await MySqlConnection.connect(
      ConnectionSettings(
        host: DbSettings.host,
        port: DbSettings.port,
        db: DbSettings.dbName,
        user: DbSettings.user,
        password: DbSettings.password,
        useSSL: DbSettings.useSSL,
      ),
    );

    // Perform the database query based on the beacon's data
    final results = await conn.query('SELECT * FROM beacon WHERE macAddress = ?', [macAddress]);

    await conn.close();
    return results;
  }

  void stopScan() {
    if (_isScanning) {
      _flutterBlue.stopScan();
      _isScanning = false;
    }
  }
}
