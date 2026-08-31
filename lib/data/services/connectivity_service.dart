import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

enum ConnectivityStatus { online, poor, offline }

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final _statusController = StreamController<ConnectivityStatus>.broadcast();

  Stream<ConnectivityStatus> get onConnectivityChanged => _statusController.stream;

  Future<void> initialize() async {
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) async {
      _statusController.add(await _determineStatus(results.isNotEmpty ? results.first : ConnectivityResult.none));
    });
  }

  Future<ConnectivityStatus> checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    return await _determineStatus(results.isNotEmpty ? results.first : ConnectivityResult.none);
  }

  Future<ConnectivityStatus> _determineStatus(ConnectivityResult result) async {
    if (result == ConnectivityResult.none) {
      return ConnectivityStatus.offline;
    }
    
    try {
      final stopwatch = Stopwatch()..start();
      final response = await http.head(Uri.parse('https://1.1.1.1')).timeout(const Duration(seconds: 3));
      stopwatch.stop();
      
      if (response.statusCode == 200) {
        return stopwatch.elapsedMilliseconds > 1500 ? ConnectivityStatus.poor : ConnectivityStatus.online;
      }
      return ConnectivityStatus.offline;
    } catch (e) {
      return ConnectivityStatus.offline;
    }
  }

  void dispose() {
    _statusController.close();
  }
}
