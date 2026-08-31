import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';

class BluetoothService {
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;
  BluetoothService._internal();

  late NearbyService _nearbyService;
  StreamSubscription? _subscription;
  StreamSubscription? _receivedDataSubscription;

  final _payloadController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get onPayloadReceived => _payloadController.stream;

  List<Device> connectedDevices = [];

  Future<void> initialize() async {
    _nearbyService = NearbyService();
    await _nearbyService.init(
      serviceType: 'disasterlink',
      deviceName: 'disasterlink_node',
      strategy: Strategy.P2P_CLUSTER,
      callback: (isRunning) async {},
    );
    
    _subscription = _nearbyService.stateChangedSubscription(callback: (devicesList) {
      connectedDevices = devicesList.where((d) => d.state == SessionState.connected).toList();
    });

    _receivedDataSubscription = _nearbyService.dataReceivedSubscription(callback: (data) {
      _payloadController.add({
        'deviceId': data['deviceId'],
        'bytes': data['message'],
      });
    });
  }

  Future<void> startAdvertising() async {
    try {
      await _nearbyService.startAdvertisingPeer();
      await _nearbyService.startBrowsingForPeers();
    } catch (e) {
      // Handle permission errors
    }
  }

  Future<void> startDiscovery() async {
    try {
      await _nearbyService.startBrowsingForPeers();
    } catch (e) {
      // Handle permission errors
    }
  }

  Future<void> stopAll() async {
    await _nearbyService.stopAdvertisingPeer();
    await _nearbyService.stopBrowsingForPeers();
  }

  Future<void> sendPayload(Device device, Uint8List bytes) async {
    if (device.state == SessionState.connected) {
      await _nearbyService.sendMessage(device.deviceId, String.fromCharCodes(bytes));
    }
  }

  Future<void> broadcastPayload(Uint8List bytes) async {
    for (var device in connectedDevices) {
      await sendPayload(device, bytes);
    }
  }

  void dispose() {
    _subscription?.cancel();
    _receivedDataSubscription?.cancel();
    _payloadController.close();
  }
}
