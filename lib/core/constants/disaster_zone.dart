class DisasterZone {
  // Demo bounds for India
  static const double minLat = 6.75;
  static const double maxLat = 35.5;
  static const double minLng = 68.16;
  static const double maxLng = 97.4;

  static bool isWithinZone(double lat, double lng) {
    return lat >= minLat && lat <= maxLat && lng >= minLng && lng <= maxLng;
  }
}
