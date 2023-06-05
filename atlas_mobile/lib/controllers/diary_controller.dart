import 'package:mysql1/mysql1.dart';
import 'package:atlas_mobile/db/db_settings.dart';
import 'package:azblob/azblob.dart';
import 'package:atlas_mobile/model/diary_entry.dart';
import 'package:atlas_mobile/model/message_model.dart';
import 'package:atlas_mobile/model/media_model.dart';
import 'dart:typed_data';

class DiaryController {
  final List<DiaryEntry> _entries = [];
  final DiaryEntry entry = DiaryEntry("", "", "");
  List<DiaryEntry> get entries => List.unmodifiable(_entries);

  Future<void> addEntry(DiaryEntry entry) async {
    _entries.add(entry);

    final conn = await MySqlConnection.connect(
      ConnectionSettings(
        host: DbSettings.host,
        port: DbSettings.port,
        db: DbSettings.dbName,
        user: DbSettings.user,
        password: DbSettings.password,
        useSSL: DbSettings.useSSL,
      ),
    );

    await conn.query(
      'INSERT INTO media(url, type, messageID) VALUES (?, ?, ?)',
      [entry.fileURL, entry.fileType, entry.id],
    );

    print('Entry added: $entry');
  }

  Future<void> uploadBlob(String containerName, String blobName, List<int> bytes) async {
    var connectionString ='DefaultEndpointsProtocol=https;AccountName=atlasstoragecamul;AccountKey=MCChqVzGFufhs5zM5FP37omLoYFmGhg3+P6iPy7Y+rONgokdvQ9pqQJUBtrM7AA+TsZR0ogPP6gv+AStMOvr8A==;EndpointSuffix=core.windows.net';
    var storage = AzureStorage.parse(connectionString);

    try {
      await storage.putBlob('$containerName/$blobName', bodyBytes: Uint8List.fromList(bytes));
      print('Blob uploaded: $containerName/$blobName');
    } catch (e) {
      throw Exception('Failed to upload blob: $e');
    }
  }

  Future<int> insertMessage(Message message) async {
    final conn = await MySqlConnection.connect(
      ConnectionSettings(
        host: DbSettings.host,
        port: DbSettings.port,
        db: DbSettings.dbName,
        user: DbSettings.user,
        password: DbSettings.password,
        useSSL: DbSettings.useSSL,
      ),
    );

    var result = await conn.query(
      'INSERT INTO message(title, description, userId) VALUES (?, ?, ?)',
      [message.title, message.description, message.userId],
    );

    print('Message inserted: $message');

    return result.insertId!;
  }

  Future<void> insertMedia(Media media) async {
    final conn = await MySqlConnection.connect(
      ConnectionSettings(
        host: DbSettings.host,
        port: DbSettings.port,
        db: DbSettings.dbName,
        user: DbSettings.user,
        password: DbSettings.password,
        useSSL: DbSettings.useSSL,
      ),
    );

    await conn.query(
      'INSERT INTO media(url, type, messageID) VALUES (?, ?, ?)',
      [media.url, media.type, media.messageID],
    );

    print('Media inserted: $media');
  }

  void removeEntry(DiaryEntry entry) {
    _entries.remove(entry);
  }
}
