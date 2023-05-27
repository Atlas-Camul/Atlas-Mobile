import 'package:flutter/material.dart';
import 'package:atlas_mobile/controllers/beacon_controller.dart';

import 'package:atlas_mobile/beacon_details_page.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BeaconPage extends StatefulWidget {
  const BeaconPage({super.key});

  @override
  _BeaconPageState createState() => _BeaconPageState();
}

class _BeaconPageState extends State<BeaconPage> {
  final BeaconController _beaconController = BeaconController();

  @override
  void initState() {
    super.initState();
    _beaconController.checkPermissions();
  }

  void _navigateToBeaconDetailsPage(ScanResult scanResult) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BeaconDetailsPage(scanResult: scanResult),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              child: Text(_beaconController.isScanning ? 'Scanning...' : 'Start Scan'),
              onPressed: () {
                if (_beaconController.isScanning) {
                  _beaconController.stopScan();
                } else {
                  _beaconController.startScan();
                }
                setState(() {});
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _beaconController.scanResults.length,
                itemBuilder: (context, index) {
                  var result = _beaconController.scanResults[index];
                  return ListTile(
                    title: Text(result.device.name ?? 'Unknown'),
                    subtitle: Text(
                      'RSSI: ${result.rssi} dBm\nMAC: ${result.device.id}',
                    ),
                    onTap: () {
                      _navigateToBeaconDetailsPage(result);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
