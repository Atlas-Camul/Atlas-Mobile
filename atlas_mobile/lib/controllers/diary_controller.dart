
import 'package:atlas_mobile/model/diary_entry.dart';
import 'package:mysql1/mysql1.dart';
import 'package:atlas_mobile/db/db_settings.dart';


class DiaryController {
  final List<DiaryEntry> _entries = [];
   final DiaryEntry entry = DiaryEntry("","","");
  List<DiaryEntry> get entries => List.unmodifiable(_entries);

  Future<void> addEntry(DiaryEntry entry) async{
    _entries.add(entry);
  

  
  final conn = await MySqlConnection.connect(
      ConnectionSettings(
        host: DbSettings.host,
        port: DbSettings.port,
        db: DbSettings.dbName,
        user: DbSettings.user,
        password: DbSettings.password,
        useSSL: DbSettings.useSSL
     
      ),
    );

  await conn.query(
      'INSERT INTO media(url, type, messageID) VALUES (?, ?, ?)',
      [entry.url, entry.type, entry.id],
    );









}















  

  void removeEntry(DiaryEntry entry) {
    _entries.remove(entry);
  }
















}