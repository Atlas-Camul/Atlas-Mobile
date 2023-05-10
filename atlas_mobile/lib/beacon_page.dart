import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BeaconPage extends StatefulWidget {
  @override
  _BeaconPageState createState() => _BeaconPageState();
}

class _BeaconPageState extends State<BeaconPage> {
  FlutterBluePlus _flutterBlue = FlutterBluePlus.instance;
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    var status = await Permission.location.status;
    if (status != PermissionStatus.granted) {
      await Permission.location.request();
    }
    _startScan();
  }

  void _startScan() {
    if (_isScanning) {
      return;
    }
    _isScanning = true;
    _scanResults.clear(); // Reset the list before starting a new scan
    _flutterBlue.scan(timeout: Duration(seconds: 5)).listen((scanResult) {
      setState(() {
        _scanResults.add(scanResult);
      });
    }).onDone(() {
      setState(() {
        _isScanning = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Beacon Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              child: Text(_isScanning ? 'Scanning...' : 'Start Scan'),
              onPressed: _startScan,
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _scanResults.length,
                itemBuilder: (context, index) {
                  var result = _scanResults[index];
                  return ListTile(
                    title: Text(result.device.name ?? 'Unknown'),
                    subtitle: Text(
                      'RSSI: ${result.rssi} dBm\nMAC: ${result.device.id}',
                    ),
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
