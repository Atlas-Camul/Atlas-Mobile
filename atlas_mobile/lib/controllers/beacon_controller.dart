
import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mysql1/mysql1.dart';
import 'package:atlas_mobile/db/db_settings.dart';

import '../model/beacon_model.dart';

class BeaconController {
  FlutterBluePlus _flutterBlue = FlutterBluePlus.instance;
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;

  List<ScanResult> get scanResults => _scanResults;
  bool get isScanning => _isScanning;

final StreamController<List<ScanResult>> _scanResultsController =
      StreamController<List<ScanResult>>.broadcast();
  Stream<List<ScanResult>> get scanResultsStream =>
      _scanResultsController.stream;




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
      _scanResultsController.add(_scanResults.toList()); // Add the updated scan results to the stream
      // Connect to the beacon and retrieve information from the database
  
    }).onDone(() {
      _isScanning = false;
    });
  }


 Future<Marker?> createMarkerFromBeacon(ScanResult scanResult) async {
    // Establish a connection with the beacon
  var device = scanResult.device;
  //  await device.connect();

    // Query the database for information based on the beacon's data
    String macAddress =device.id.toString();

    var databaseResult = await yourDatabaseQueryFunction(macAddress);
    var latitude = databaseResult.first['latitude'];
    var longitude = databaseResult.first['longitude'];
   

  var beacon = Beacon(
  macAddress: macAddress,
  latitude: latitude,
  longitude: longitude,
);

//device.disconnect();
    

if (latitude != null && longitude != null) {
  var marker = Marker(
    markerId: MarkerId(macAddress),
    position: LatLng(double.parse(latitude), double.parse(longitude)),
    icon: BitmapDescriptor.defaultMarker
  );

  return marker;
} else {
  print("ERRO");
  return null;
}


  }



    












  Future<dynamic> yourDatabaseQueryFunction(String macAddress)async{
    // Replace this function with your own database retrieval logic
    // Example: Query the database using the beacon's MAC address
    // Return the retrieved information
    // Example: return yourDatabase.query(macAddress);
 
 // Connect to the database
    final conn = await MySqlConnection.connect(
      ConnectionSettings(
        host: DbSettings.host,
        port: DbSettings.port,
        db: DbSettings.dbName,
        user: DbSettings.user,
        password: DbSettings.password,
        useSSL: DbSettings.useSSL
     
      ),
    );
    
 
    
    final results = await conn.query('SELECT * FROM beacon WHERE macAddress = ? ',[macAddress]);

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