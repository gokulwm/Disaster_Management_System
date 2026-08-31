import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:disaster_link/presentation/theme/app_theme.dart';

class MapMarkerLayer extends StatelessWidget {
  const MapMarkerLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return const MarkerLayer(
      markers: [
        Marker(
          point: LatLng(0, 0),
          width: 40,
          height: 40,
          child: Icon(Icons.location_on, color: AppTheme.primary, size: 40),
        ),
      ],
    );
  }
}
