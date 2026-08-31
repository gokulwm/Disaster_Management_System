import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:disaster_link/data/services/bluetooth_service.dart';
import 'package:disaster_link/data/services/encryption_service.dart';
import 'package:disaster_link/data/datasources/local_db_datasource.dart';
import 'package:disaster_link/data/services/connectivity_service.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class BtPayload {
  final String uuid;
  final String payloadHash;
  final String data;
  final String originDeviceId;
  final int hopCount;
  final List<String> deviceChain;
  final int createdAtMs;

  BtPayload({
    required this.uuid,
    required this.payloadHash,
    required this.data,
    required this.originDeviceId,
    required this.hopCount,
    required this.deviceChain,
    required this.createdAtMs,
  });

  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'payload_hash': payloadHash,
    'data': data,
    'origin_device_id': originDeviceId,
    'hop_count': hopCount,
    'device_chain': deviceChain,
    'created_at_ms': createdAtMs,
  };

  factory BtPayload.fromJson(Map<String, dynamic> json) => BtPayload(
    uuid: json['uuid'],
    payloadHash: json['payload_hash'],
    data: json['data'],
    originDeviceId: json['origin_device_id'],
    hopCount: json['hop_count'],
    deviceChain: List<String>.from(json['device_chain'] ?? []),
    createdAtMs: json['created_at_ms'],
  );
}

class BtDatasource {
  static final BtDatasource _instance = BtDatasource._internal();
  factory BtDatasource() => _instance;
  BtDatasource._internal();

  final BluetoothService _btService = BluetoothService();
  final EncryptionService _encryptionService = EncryptionService();
  final LocalDbDatasource _db = LocalDbDatasource();
  final ConnectivityService _connectivity = ConnectivityService();
  
  String _myDeviceId = 'unknown';

  Future<void> initialize() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      _myDeviceId = androidInfo.id;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      _myDeviceId = iosInfo.identifierForVendor ?? 'unknown_ios';
    }

    _btService.onPayloadReceived.listen((event) {
      final bytes = event['bytes'];
      if (bytes != null) {
        receivePayload(utf8.encode(bytes));
      }
    });
  }

  Future<BtPayload> preparePayload(String uuid, Map<String, dynamic> dataObj) async {
    final rawData = jsonEncode(dataObj);
    final encryptedData = _encryptionService.encrypt(rawData);
    
    final hashBytes = sha256.convert(utf8.encode(encryptedData)).bytes;
    final payloadHash = base64Encode(hashBytes);

    return BtPayload(
      uuid: uuid,
      payloadHash: payloadHash,
      data: encryptedData,
      originDeviceId: _myDeviceId,
      hopCount: 0,
      deviceChain: [_myDeviceId],
      createdAtMs: DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<void> receivePayload(List<int> bytes) async {
    try {
      final jsonStr = utf8.decode(bytes);
      final jsonMap = jsonDecode(jsonStr);
      final payload = BtPayload.fromJson(jsonMap);

      if (payload.hopCount > 8) return;
      if (payload.deviceChain.contains(_myDeviceId)) return;
      
      final seen = await _db.isPayloadSeen(payload.payloadHash);
      if (seen) return;

      final existing = await _db.getLocalHelpRequest(payload.uuid);
      if (existing != null && existing['created_at_ms'] >= payload.createdAtMs) {
        return;
      }

      await _db.markPayloadSeen(payload.payloadHash);
      await _db.upsertLocalHelpRequest(payload.uuid, payload.data, payload.createdAtMs);

      if (isVolunteerData()) {
        final decryptedStr = _encryptionService.decrypt(payload.data);
        if (decryptedStr.isNotEmpty) {
          final decryptedData = jsonDecode(decryptedStr);
          await _db.insertToQueue(payload.uuid, 'help_request', jsonEncode(decryptedData));
        }
      } else {
        await _db.insertToQueue(payload.uuid, 'help_request', payload.data);
      }

      final status = await _connectivity.checkConnectivity();
      if (status != ConnectivityStatus.online) {
        await relayPayload(payload);
      }
    } catch (e) {
      // Decode error or validation failure
    }
  }

  Future<void> relayPayload(BtPayload payload) async {
    payload.deviceChain.add(_myDeviceId);
    final nextHopPayload = BtPayload(
      uuid: payload.uuid,
      payloadHash: payload.payloadHash,
      data: payload.data,
      originDeviceId: payload.originDeviceId,
      hopCount: payload.hopCount + 1,
      deviceChain: payload.deviceChain,
      createdAtMs: payload.createdAtMs,
    );
    
    final bytes = utf8.encode(jsonEncode(nextHopPayload.toJson()));
    await _btService.broadcastPayload(bytes);
  }

  bool isVolunteerData() {
    return _encryptionService.isVolunteerDevice();
  }
}
