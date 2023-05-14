import 'package:flutter/material.dart';

class DiaryEntryScreen extends StatefulWidget {
  @override
  _DiaryEntryScreenState createState() => _DiaryEntryScreenState();
}

class _DiaryEntryScreenState extends State<DiaryEntryScreen> {
 
 
 
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
                        onTap: () {},
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
