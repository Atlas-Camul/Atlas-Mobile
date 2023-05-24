import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:atlas_mobile/model/diary_entry.dart';
import 'package:atlas_mobile/controllers/diary_controller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:azblob/azblob.dart';
class DiaryPage extends StatefulWidget {
  const DiaryPage({Key? key}) : super(key: key);

  @override
  _DiaryPageState createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  final DiaryController _controller = DiaryController();
  final TextEditingController _textEditingController = TextEditingController();
  File? _image;

  FlutterSoundRecorder? _audioRecorder;
  FlutterSoundPlayer? _audioPlayer;
  String _audioPath = '';
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _audioRecorder = FlutterSoundRecorder();
    _audioPlayer = FlutterSoundPlayer();
    _initAudioRecorder();
  }

  @override
  void dispose() {
    _audioRecorder?.closeRecorder();
    _audioPlayer?.closePlayer();
    super.dispose();
  }

  Future<void> _initAudioRecorder() async {
    await _audioRecorder?.openRecorder();
  }

  Future<void> _requestPermission() async {
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      _toggleRecording();
    } else {
      print('Permission denied.');
    }
  }

  void _toggleRecording() async {
    if (!_isRecording) {
      try {
        await _audioRecorder?.startRecorder(
          toFile: 'audio_recording.aac',
          codec: Codec.aacADTS,
        );
        setState(() {
          _audioPath = '';
          _isRecording = true;
        });
      } catch (e) {
        print('Failed to start recording: $e');
      }
    } else {
      try {
        final audioPath = await _audioRecorder?.stopRecorder();
        setState(() {
          _audioPath = audioPath ?? '';
          _isRecording = false;
        });
      } catch (e) {
        print('Failed to stop recording: $e');
      }
    }
  }

  void _playRecording() async {
    try {
      await _audioPlayer?.openPlayer();
      await _audioPlayer?.startPlayer(
        fromURI: _audioPath,
        codec: Codec.aacADTS,
      );
    } catch (e) {
      print('Failed to play recording: $e');
    }
  }

  void _stopPlayback() async {
    try {
      await _audioPlayer?.stopPlayer();
    } catch (e) {
      print('Failed to stop playback: $e');
    }
  }

  // Adds a new entry to the diary
  void _addEntry() async {
    final text = _textEditingController.text;
    if (text.isNotEmpty) {
      final entry = DiaryEntry(
        id: DateTime.now().toString(),
        text: text,
        image: _image,
        audioPath: _audioPath.isNotEmpty ? _audioPath : null,
        createdAt: DateTime.now(),
      );
     if (_image != null) {
      // Upload the image to Azure Blob Storage
      var connectionString =
      'DefaultEndpointsProtocol=https;AccountName=atlascamulstorage;AccountKey=IwNJ988R3R7rJ9j9vwMsls5bz9M5NC+TWO+Xs26MO3NQHkycdEtOcoye6Qado/x2tcrWWO1DY6S3+AStlqAvPA==;EndpointSuffix=core.windows.net';
      var storage = AzureStorage.parse(connectionString);

      // Specify the container and blob name for the uploaded image
      var container = 'teste';
      var blobName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Read the image file as bytes
      var bytes = await _image!.readAsBytes();

      try {
        // Upload the image to Azure Blob Storage
        await storage.putBlob('$container/$blobName', bodyBytes: bytes);

        // Set the image URL in the diary entry
       // entry.imageURL = '$container/$blobName';
      } catch (e) {
        // Handle the error
        print('Error uploading image: $e');
        // You can show an error message to the user or perform other error handling tasks here
        return;
      }

      // Set the image URL in the diary entry
     // entry.imageURL = '$container/$blobName';
    }
      setState(() {
        //_controller.addEntry(entry);
        _textEditingController.clear();
        _image = null;
        _audioPath = '';
      });
    }
  }

  // Allows the user to pick an image from the gallery
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  bool _showMediaOptions = false;

  void _toggleMediaOptions() {
    setState(() {
      _showMediaOptions = !_showMediaOptions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Diary Entry'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: TextFormField(
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: 'Write your diary entry here...',
                  border: InputBorder.none,
                ),
                controller: _textEditingController,
              ),
            ),
            SizedBox(height: 16),
            _buildMediaButton(
              icon: Icons.add_circle_outline,
              text: 'Add Media',
              onTap: _toggleMediaOptions,
            ),
            SizedBox(height: 16),
            _showMediaOptions
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMediaButton(
                        icon: Icons.photo,
                        text: 'Photo',
                        onTap: _pickImage,
                      ),
                      _buildMediaButton(
                        icon: Icons.videocam,
                        text: 'Video',
                        onTap: () {},
                      ),
                      _buildMediaButton(
                        icon: Icons.mic,
                        text: _isRecording ? 'Stop' : 'Record',
                        onTap: _requestPermission,
                      ),
                    ],
                  )
                : Container(),
            SizedBox(height: 16),
            _audioPath.isNotEmpty
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.play_arrow),
                        onPressed: _playRecording,
                      ),
                      IconButton(
                        icon: Icon(Icons.stop),
                        onPressed: _stopPlayback,
                      ),
                    ],
                  )
                : Container(),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addEntry,
              child: Text('Save Entry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaButton({required IconData icon, required String text, required Function onTap}) {
    return InkWell(
      onTap: () {
        if (onTap is void Function()) {
          onTap();
        }
      },
      child: Column(
        children: [
          Icon(icon),
          SizedBox(height: 8),
          Text(text),
        ],
      ),
    );
  }
}
