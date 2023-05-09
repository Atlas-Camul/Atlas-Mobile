import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BeaconPage extends StatefulWidget {
  @override
  _BeaconPageState createState() => _BeaconPageState();
}

class _BeaconPageState extends State<BeaconPage> {
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  List<ScanResult> scanResults = [];

  @override
  void initState() {
    super.initState();
    _startScanning();
  }

  @override
  void dispose() {
    flutterBlue.stopScan();
    super.dispose();
  }

  void _startScanning() {
    flutterBlue.scan().listen((scanResult) {
      setState(() {
        // Update the list of scan results
        scanResults.add(scanResult);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Beacon Page'),
      ),
      body: ListView.builder(
        itemCount: scanResults.length,
        itemBuilder: (BuildContext context, int index) {
          var scanResult = scanResults[index];
          var name = scanResult.device.name;
          var uuid = scanResult.device.id.toString();
          var rssi = scanResult.rssi.toString();
          var manufacturerData = scanResult.advertisementData.manufacturerData;
          var data = '';
          if (manufacturerData.isNotEmpty) {
            data = manufacturerData.entries
                .map((entry) => '${entry.key}: ${entry.value}\n')
                .join();
          }

          return ListTile(
            title: Text(name ?? 'Unknown device'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('UUID: $uuid'),
                Text('RSSI: $rssi dBm'),
                Text('Data: $data'),
              ],
            ),
          );
        },
      ),
    );
  }
}
