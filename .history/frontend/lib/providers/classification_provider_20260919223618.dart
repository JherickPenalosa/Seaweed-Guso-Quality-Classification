import 'package:flutter/material.dart';

import '../models/classification_record.dart';

class ClassificationProvider extends ChangeNotifier {
  final List<ClassificationRecord> _records = [];

  ClassificationRecord? _selectedRecord;

  List<ClassificationRecord> get records =>
      List.unmodifiable(_records);

  ClassificationRecord? get selectedRecord =>
      _selectedRecord;

  bool get hasRecords => _records.isNotEmpty;

  void addRecord(ClassificationRecord record) {
    _records.insert(0, record);
    _selectedRecord = record;

    notifyListeners();
  }

  void selectRecord(ClassificationRecord record) {
    _selectedRecord = record;

    notifyListeners();
  }

  void clearSelectedRecord() {
    _selectedRecord = null;

    notifyListeners();
  }

  void removeRecord(String recordId) {
    final wasSelected =
        _selectedRecord?.id == recordId;

    _records.removeWhere(
      (record) => record.id == recordId,
    );

    if (wasSelected) {
      _selectedRecord =
          _records.isNotEmpty ? _records.first : null;
    }

    notifyListeners();
  }

  void clearHistory() {
    _records.clear();
    _selectedRecord = null;

    notifyListeners();
  }
}