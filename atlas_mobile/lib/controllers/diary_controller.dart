import 'package:flutter/material.dart';
import 'package:atlas_mobile/model/diary_entry.dart';


class DiaryController {
  final List<DiaryEntry> _entries = [];

  List<DiaryEntry> get entries => List.unmodifiable(_entries);

  void addEntry(DiaryEntry entry) {
    _entries.add(entry);
  }

  void removeEntry(DiaryEntry entry) {
    _entries.remove(entry);
  }
}