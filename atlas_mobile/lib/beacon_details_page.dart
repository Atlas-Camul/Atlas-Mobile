import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:atlas_mobile/controllers/beacon_controller.dart';
import 'package:flutter_tts/flutter_tts.dart';

class BeaconDetailsPage extends StatefulWidget {
  final ScanResult scanResult;

  const BeaconDetailsPage({Key? key, required this.scanResult}) : super(key: key);

  @override
  _BeaconDetailsPageState createState() => _BeaconDetailsPageState();
}

class _BeaconDetailsPageState extends State<BeaconDetailsPage> {
  final FlutterTts _flutterTts = FlutterTts();
  final BeaconController _beaconController = BeaconController();
  bool _isPlaying = false;
  String? _latitude;
  String? _longitude;

  @override
  void initState() {
    super.initState();
    _retrieveDataFromDatabase();
    _speakDetails();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _retrieveDataFromDatabase() async {
    // Replace this with your own logic to retrieve latitude and longitude from the database
    // Example: Retrieve latitude and longitude based on beacon's data
    var latitude = 'Latitude Value';
    var longitude = 'Longitude Value';

    setState(() {
      _latitude = latitude;
      _longitude = longitude;
    });
  }

  Future<void> _speakDetails() async {
    String deviceName = widget.scanResult.device.name ?? 'Unknown';
    int rssi = widget.scanResult.rssi;
    String macAddress = widget.scanResult.device.id.toString();

    String details = 'Device Name: $deviceName. RSSI: $rssi dBm. MAC Address: $macAddress';

    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.6);
    await _flutterTts.speak(details);
  }

  Future<void> _playTTS() async {
    String deviceName = widget.scanResult.device.name ?? 'Unknown';
    int rssi = widget.scanResult.rssi;
    String macAddress = widget.scanResult.device.id.toString();

    String details = 'Device Name: $deviceName. RSSI: $rssi dBm. MAC Address: $macAddress';

    if (!_isPlaying) {
      await _flutterTts.stop();
      await _flutterTts.speak(details);
      setState(() {
        _isPlaying = true;
      });
    } else {
      await _flutterTts.stop();
      setState(() {
        _isPlaying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beacon Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Beacon Details',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'Device Name: ${widget.scanResult.device.name ?? 'Unknown'}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'RSSI: ${widget.scanResult.rssi} dBm',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'MAC Address: ${widget.scanResult.device.id}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            if (_latitude != null && _longitude != null)
              Column(
                children: [
                  Text(
                    'Latitude: $_latitude',
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Longitude: $_longitude',
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _playTTS,
              child: Text(_isPlaying ? 'Stop Playback' : 'Play Details'),
            ),
          ],
        ),
      ),
    );
  }
}
