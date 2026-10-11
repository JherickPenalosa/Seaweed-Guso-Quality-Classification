import 'package:flutter/material.dart';

import '../models/classification_record.dart';

class ClassificationProvider extends ChangeNotifier {
  final List<ClassificationRecord> _records = [];

  ClassificationRecord? _selectedRecord;

  bool _isLoadingHistory = false;
  String? _historyError;

  List<ClassificationRecord> get records =>
      List.unmodifiable(_records);

  ClassificationRecord? get selectedRecord =>
      _selectedRecord;

  bool get hasRecords => _records.isNotEmpty;

  bool get isLoadingHistory => _isLoadingHistory;

  String? get historyError => _historyError;

  bool get hasHistoryError => _historyError != null;

  void addRecord(ClassificationRecord record) {
    _records.insert(0, record);
    _selectedRecord = record;

    _historyError = null;

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
    _historyError = null;

    notifyListeners();
  }

  void startHistoryLoading() {
    if (_isLoadingHistory) {
      return;
    }

    _isLoadingHistory = true;
    _historyError = null;

    notifyListeners();
  }

  void finishHistoryLoading() {
    if (!_isLoadingHistory) {
      return;
    }

    _isLoadingHistory = false;

    notifyListeners();
  }

  void setHistoryError(String message) {
    _isLoadingHistory = false;
    _historyError = message;

    notifyListeners();
  }

  void clearHistoryError() {
    if (_historyError == null) {
      return;
    }

    _historyError = null;

    notifyListeners();
  }

  void retryHistory() {
    _historyError = null;

    notifyListeners();
  }

  bool _hasUnsavedResult = false;
  bool get hasUnsavedResult => _hasUnsavedResult;

  void setUnsavedResult(bool value) {
  if (_hasUnsavedResult == value) {
    return;
  }

  _hasUnsavedResult = value;
  notifyListeners();
  }


}