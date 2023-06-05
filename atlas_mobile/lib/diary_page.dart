import 'package:atlas_mobile/colors/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:atlas_mobile/model/diary_entry.dart';
import 'package:atlas_mobile/controllers/diary_controller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:azblob/azblob.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atlas_mobile/model/message_model.dart';
import 'package:atlas_mobile/model/media_model.dart';

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

void _addEntry() async {
  final text = _textEditingController.text;

  if (text.isNotEmpty && (_audioPath.isNotEmpty || _image != null)) {
    if (_audioPath.isNotEmpty && _image != null) {
      // Delete existing image if an audio is added
      await _deleteFile();
      setState(() {
        _image = null; // Remove image file from the state
      });
    }
    // Get the current user ID from shared preferences
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('id');

   if (userId != null) {
    // Create a new message entry
    var message = Message(
      id: 0,
      title: '',
      description: text,
      latitude: '',
      longitude: '',
      zoneID: 1,
      userId: userId,
    );

    // Insert the message entry in the database
    int messageId = await _controller.insertMessage(message);

    // Create a new media entry
    var media = Media(
      id: 0,
      url: '',
      type: '',
      messageID: messageId,
    );

    if (_image != null) {
      var blobName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      var bytes = await _image!.readAsBytes();

      try {
        // Upload the image to Azure Blob storage
        await _controller.uploadBlob('teste', blobName, bytes);

        // Set the media properties
        media.url = blobName;
        media.type = 'image';
      } catch (e) {
        print('Error uploading image: $e');
        return;
      }
    }

    if (_audioPath.isNotEmpty) {
      var extension = _audioPath.split('.').last;
      var blobName = 'audio_${DateTime.now().millisecondsSinceEpoch}.$extension';

      try {
        // Read the audio file as bytes
        var bytes = await File(_audioPath).readAsBytes();

        // Upload the audio to Azure Blob storage
        await _controller.uploadBlob('teste', blobName, bytes);

        // Set the media properties
        media.url = blobName;
        media.type = 'audio';
      } catch (e) {
        print('Error uploading audio: $e');
        return;
      }
    }

    // Insert the media entry in the database
    await _controller.insertMedia(media);

    // Reset the input fields
    _textEditingController.clear();
    setState(() {
      _image = null;
      _audioPath = '';
    });
  }
  }
}

  // Delete the file (image or audio)
  Future<void> _deleteFile() async{
    setState(() {
      _image = null;
      _audioPath = '';
    });
  }

  // Allows the user to pick an image from the gallery
  void _pickImage() async {
    
      if (_image != null) {
      _deleteFile();
    }
    
    
    
    
    
    
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
   
   if (_image != null || _audioPath.isNotEmpty) {
      _deleteFile();
    }
   
   
   
   
   
   
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
        backgroundColor: AppColors.primaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: 'Write your diary entry here...',
                  border: OutlineInputBorder(),
                ),
                controller: _textEditingController,
              ),
              SizedBox(height: 16),
              _buildMediaButton(
                icon: Icons.add_photo_alternate,
                text: 'Add Image',
                onTap: _pickImage,
              ),
              SizedBox(height: 16),
              _image != null
                  ? Column(
                      children: [
                        Image.file(_image!),
                        ElevatedButton(
                          onPressed: _deleteFile,
                          child: Text('Delete Image'),
                        ),
                      ],
                    )
                  : Container(),
              SizedBox(height: 16),
              _buildMediaButton(
                icon: Icons.mic,
                text: _isRecording ? 'Stop Recording' : 'Start Recording',
                onTap: _requestPermission,
              ),
              SizedBox(height: 16),
              _audioPath.isNotEmpty
                  ? Column(
                      children: [
                        ElevatedButton(
                          onPressed: _playRecording,
                          child: Text('Play Recording'),
                        ),
                        ElevatedButton(
                          onPressed: _stopPlayback,
                          child: Text('Stop Playback'),
                        ),
                        ElevatedButton(
                          onPressed: _deleteFile,
                          child: Text('Delete Audio'),
                        ),
                      ],
                    )
                  : Container(),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addEntry,
                child: Text('Add Entry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon),
          SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}
