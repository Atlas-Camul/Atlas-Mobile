// View class
import 'package:flutter/material.dart';
import 'package:atlas_mobile/model/diary_entry.dart';
import 'package:atlas_mobile/controllers/diary_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/services.dart';
class DiaryPage extends StatefulWidget {
  const DiaryPage({Key? key}) : super(key: key);

  @override
  _DiaryPageState createState() => _DiaryPageState();
}









class _DiaryPageState extends State<DiaryPage> {
  final DiaryController _controller = DiaryController();
  final TextEditingController _textEditingController = TextEditingController();
  File? _image;

  
  
  

    // Adds a new entry to the diary
 void _addEntry() {
  final text = _textEditingController.text;
  if (text.isNotEmpty) {
    final entry = DiaryEntry(
      id: DateTime.now().toString(),
      text: text,
      image: _image,
      //audioPath: _audioPlayer.sequence?.isEmpty ?? true ? null : _audioPlayer.sequence!.first.tag as String?,
      createdAt: DateTime.now(),
    );
    setState(() {
      _controller.addEntry(entry);
      _textEditingController.clear();
      _image = null;
      //_audioPlayer.stop();
      //_isRecording = false;
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
                        text: 'Voice',
                        onTap: () {},
                      ),
                    ],
                  )
                : Container(),
            
            
            
            
            
    
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
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
