import 'package:disaster_link/core/constants/disaster_zone.dart';

class GeofenceValidator {
  static bool validateCoordinates(double lat, double lng) {
    return DisasterZone.isWithinZone(lat, lng);
  }
}
