import 'dart:io';

class DiaryEntry {
  final String id;
  final String text;
  final File? image;
  final File? video;
  final String? audioPath;
  final DateTime createdAt;
  
  DiaryEntry({
    required this.id,
    required this.text,
    required this.createdAt,
    this.image,
    this.video,
    this.audioPath,
  
  
  });
}