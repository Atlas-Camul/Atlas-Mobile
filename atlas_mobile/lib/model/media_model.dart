class Media {
  final int id;
   String url;
   String type;
  final int messageID; // Foreign key

  Media({
    required this.id,
    required this.url,
    required this.type,
    required this.messageID,
    
  });
}
