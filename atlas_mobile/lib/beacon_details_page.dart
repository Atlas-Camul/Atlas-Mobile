import 'package:flutter/material.dart';
import 'package:atlas_mobile/controllers/beacon_controller.dart';
import 'package:atlas_mobile/db/db_settings.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_tts/flutter_tts.dart';

class BeaconDetailsPage extends StatefulWidget {
  final ScanResult scanResult;

  BeaconDetailsPage({required this.scanResult});

  @override
  _BeaconDetailsPageState createState() => _BeaconDetailsPageState();
}

class _BeaconDetailsPageState extends State<BeaconDetailsPage> {
  FlutterTts _flutterTts = FlutterTts();
  BeaconController _beaconController = BeaconController();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _speakDetails();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
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
        title: Text('Beacon Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Beacon Details',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Device Name: ${widget.scanResult.device.name ?? 'Unknown'}',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'RSSI: ${widget.scanResult.rssi} dBm',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'MAC Address: ${widget.scanResult.device.id}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text(_isPlaying ? 'Stop Playback' : 'Play Details'),
              onPressed: _playTTS,
            ),
          ],
        ),
      ),
    );
  }
}
