// lib/providers/scan_provider.dart
import 'package:flutter/material.dart';
import '../core/state/data_status.dart';
import '../models/scan_result_model.dart';
import '../repositories/scan_repository.dart';

class ScanProvider with ChangeNotifier {
  final ScanRepository _scanRepository;

  ScanProvider({ScanRepository? repository})
      : _scanRepository = repository ?? ScanRepository();

  DataStatus _status = DataStatus.initial;
  DataStatus get status => _status;

  ScanResultModel? _lastResult;
  ScanResultModel? get lastResult => _lastResult;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void reset() {
    _status = DataStatus.initial;
    _lastResult = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> performScan(String imagePath, {required String task}) async {
    _status = DataStatus.loading;
    notifyListeners();

    try {
      _lastResult = await _scanRepository.analyzePlant(imagePath, task: task);
      _status = DataStatus.success;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _status = DataStatus.error;
      notifyListeners();
    }
  }
}
