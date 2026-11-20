import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/classification_record.dart';
import '../models/classification_result.dart';
import '../services/mobile_auth_service.dart';

class ClassificationProvider extends ChangeNotifier {
  static const String _baseUrl = String.fromEnvironment(
    'GUSO_API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  static const Duration _timeout = Duration(seconds: 40);

  final List<ClassificationRecord> _records = [];

  ClassificationRecord? _selectedRecord;

  bool _isLoadingHistory = false;
  bool _historyLoaded = false;
  bool _historyLoadScheduled = false;
  bool _disposed = false;

  String? _historyError;
  String? _sessionToken;

  int _requestGeneration = 0;

  Directory? _imageCacheDirectory;

  bool _hasUnsavedResult = false;
  int _discardVersion = 0;

  // Automatically request saved history when a screen
  // accesses records under a new authenticated session.
  List<ClassificationRecord> get records {
    _scheduleHistoryLoad();

    final token = MobileAuthService.accessToken;

    if (token == null || token.isEmpty || token != _sessionToken) {
      return const <ClassificationRecord>[];
    }

    return List.unmodifiable(_records);
  }

  ClassificationRecord? get selectedRecord => _selectedRecord;

  bool get isLoadingHistory => _isLoadingHistory;

  String? get historyError => _historyError;

  bool get hasUnsavedResult => _hasUnsavedResult;

  int get discardVersion => _discardVersion;

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  void _scheduleHistoryLoad() {
    final token = MobileAuthService.accessToken;

    if (token == null || token.isEmpty || _disposed) {
      return;
    }

    if (_historyLoadScheduled) return;

    if (_sessionToken == token && (_historyLoaded || _isLoadingHistory)) {
      return;
    }

    _historyLoadScheduled = true;

    // Schedule after build to avoid notifying listeners
    // while Flutter is building the History screen.
    scheduleMicrotask(() {
      _historyLoadScheduled = false;

      if (!_disposed) {
        unawaited(loadSavedHistory());
      }
    });
  }

  bool _isCurrentRequest(String token, int generation) {
    return !_disposed &&
        _requestGeneration == generation &&
        _sessionToken == token &&
        MobileAuthService.accessToken == token;
  }

  Future<void> loadSavedHistory() async {
    final token = MobileAuthService.accessToken;

    if (token == null || token.isEmpty) {
      _requestGeneration++;

      _records.clear();
      _selectedRecord = null;
      _sessionToken = null;
      _historyLoaded = false;
      _isLoadingHistory = false;

      _historyError = 'Please sign in to view your saved history.';

      await _clearImageCache();

      _notify();
      return;
    }

    if (_isLoadingHistory && _sessionToken == token) {
      return;
    }

    final generation = ++_requestGeneration;

    if (_sessionToken != token) {
      // Never display records from a previous account.
      _records.clear();
      _selectedRecord = null;
      _sessionToken = token;
      _historyLoaded = false;

      await _clearImageCache();

      if (!_isCurrentRequest(token, generation)) {
        return;
      }
    }

    _isLoadingHistory = true;
    _historyError = null;

    _notify();

    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/history/me'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(_timeout);

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw const FormatException(
          'Your session has expired. Please log in again.',
        );
      }

      if (response.statusCode != 200) {
        throw FormatException(
          'Unable to load saved history '
          '(HTTP ${response.statusCode}).',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map) {
        throw const FormatException('Invalid history response from FastAPI.');
      }

      final rawRecords = decoded['records'];

      if (rawRecords is! List) {
        throw const FormatException(
          'FastAPI did not return a valid history list.',
        );
      }

      final existing = {for (final record in _records) record.id: record};

      final fetchedRecords = <ClassificationRecord>[];

      for (final raw in rawRecords) {
        if (!_isCurrentRequest(token, generation)) {
          return;
        }

        if (raw is! Map) continue;

        final data = Map<String, dynamic>.from(raw);

        final id = int.tryParse(data['id']?.toString() ?? '');

        if (id == null || id <= 0) continue;

        final previous = existing[id];

        if (previous != null && previous.imagePath.isNotEmpty) {
          try {
            if (await File(previous.imagePath).exists()) {
              fetchedRecords.add(previous);
              continue;
            }
          } on FileSystemException {
            // Download the saved image again.
          }
        }

        String imagePath = '';

        if (data['has_image'] == true) {
          try {
            imagePath = await _downloadSavedImage(
              classificationId: id,
              token: token,
            );
          } catch (_) {
            // Keep the saved record even if its image
            // cannot currently be downloaded.
          }
        }

        final rawAnalysis = data['analysis_result'];

        final analysis = rawAnalysis is Map
            ? Map<String, dynamic>.from(rawAnalysis)
            : <String, dynamic>{};

        final result = ClassificationResult.fromJson({
          ...analysis,
          'classification_id': id,

          // The model classifies quality; it does not
          // independently verify seaweed species.
          'species': 'Species not verified',

          'quality_grade': data['quality_grade'] ?? analysis['quality_grade'],

          'confidence': data['confidence'] ?? analysis['confidence'] ?? 0,

          'model_name': data['model'] ?? analysis['model_name'],

          'summary': analysis['message'] ?? 'Saved classification.',
        });

        final savedDate =
            DateTime.tryParse(data['date']?.toString() ?? '') ?? DateTime.now();

        fetchedRecords.add(
          ClassificationRecord(
            id: id,
            imagePath: imagePath,
            result: result,
            createdAt: savedDate,
          ),
        );
      }

      if (!_isCurrentRequest(token, generation)) {
        return;
      }

      // Keep any newly saved in-session records that
      // were added while history was loading.
      final combined = {for (final record in _records) record.id: record};

      for (final record in fetchedRecords) {
        combined.putIfAbsent(record.id, () => record);
      }

      _records
        ..clear()
        ..addAll(combined.values);

      _historyLoaded = true;
      _historyError = null;
    } catch (error) {
      if (!_isCurrentRequest(token, generation)) {
        return;
      }

      _historyLoaded = true;

      _historyError = error is FormatException
          ? error.message
          : 'Unable to retrieve saved history. '
                'Check the connection to FastAPI and try again.';
    } finally {
      if (_isCurrentRequest(token, generation)) {
        _isLoadingHistory = false;
        _notify();
      }
    }
  }

  Future<String> _downloadSavedImage({
    required int classificationId,
    required String token,
  }) async {
    final response = await http
        .get(
          Uri.parse('$_baseUrl/history/$classificationId/image'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(_timeout);

    if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
      return '';
    }

    final contentType = response.headers['content-type']
        ?.split(';')
        .first
        .trim()
        .toLowerCase();

    final String extension;

    if (contentType == 'image/png') {
      extension = 'png';
    } else if (contentType == 'image/jpeg') {
      extension = 'jpg';
    } else {
      return '';
    }

    _imageCacheDirectory ??= await Directory.systemTemp.createTemp(
      'guso_saved_history_',
    );

    final separator = Platform.pathSeparator;

    final file = File(
      '${_imageCacheDirectory!.path}'
      '${separator}classification_$classificationId.$extension',
    );

    await file.writeAsBytes(response.bodyBytes, flush: true);

    return file.path;
  }

  Future<void> _clearImageCache() async {
    final directory = _imageCacheDirectory;
    _imageCacheDirectory = null;

    if (directory == null) return;

    try {
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    } catch (_) {
      // Temporary-cache cleanup is best-effort.
    }
  }

  void discardCurrentResult() {
    _hasUnsavedResult = false;
    _discardVersion++;
    _notify();
  }

  void addRecord(ClassificationRecord record) {
    final token = MobileAuthService.accessToken;

    if (_sessionToken != token) {
      _records.clear();
      _selectedRecord = null;
      _sessionToken = token;
      _historyLoaded = false;

      unawaited(_clearImageCache());
    }

    _records.removeWhere((item) => item.id == record.id);

    _records.insert(0, record);

    _notify();
  }

  void removeRecord(int id) {
    _records.removeWhere((record) => record.id == id);

    if (_selectedRecord?.id == id) {
      _selectedRecord = null;
    }

    _notify();
  }

  // Currently clears the visible Flutter list only.
  // Server-side deletion requires a separate API action.
  void clearHistory() {
    _requestGeneration++;

    _records.clear();
    _selectedRecord = null;
    _isLoadingHistory = false;
    _historyLoaded = true;

    _notify();
  }

  void selectRecord(ClassificationRecord? record) {
    _selectedRecord = record;
    _notify();
  }

  void setUnsavedResult(bool value) {
    if (_hasUnsavedResult == value) return;

    _hasUnsavedResult = value;
    _notify();
  }

  void startHistoryLoading() {
    _isLoadingHistory = true;
    _historyError = null;
    _notify();
  }

  void finishHistoryLoading() {
    _isLoadingHistory = false;
    _notify();
  }

  void setHistoryError(String message) {
    _isLoadingHistory = false;
    _historyError = message;
    _notify();
  }

  void clearHistoryError() {
    _historyError = null;
    _notify();
  }

  // The old simulated 500 ms retry is replaced with
  // a real request to PostgreSQL through FastAPI.
  void retryHistory() {
    unawaited(loadSavedHistory());
  }

  @override
  void dispose() {
    _disposed = true;
    _requestGeneration++;

    unawaited(_clearImageCache());

    super.dispose();
  }
}
