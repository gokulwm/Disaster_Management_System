import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:disaster_link/blocs/marker/marker_bloc.dart';
import 'package:disaster_link/data/models/marker.dart' as app_marker;
import 'package:disaster_link/data/services/location_service.dart';
import 'package:disaster_link/presentation/theme/app_theme.dart';

class AddMarkerScreen extends StatefulWidget {
  const AddMarkerScreen({super.key});

  @override
  State<AddMarkerScreen> createState() => _AddMarkerScreenState();
}

class _AddMarkerScreenState extends State<AddMarkerScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final MapController _mapController = MapController();

  LatLng? _selectedLocation;
  String _selectedType = 'food';
  bool _loadingLocation = true;

  final List<Map<String, dynamic>> _markerTypes = [
    {'key': 'food', 'label': 'Food', 'icon': Icons.restaurant, 'color': AppTheme.secondary},
    {'key': 'shelter', 'label': 'Shelter', 'icon': Icons.home, 'color': Colors.blue},
    {'key': 'danger', 'label': 'Danger', 'icon': Icons.warning, 'color': AppTheme.danger},
    {'key': 'medical', 'label': 'Medical', 'icon': Icons.local_pharmacy, 'color': AppTheme.primary},
    {'key': 'grocery', 'label': 'Grocery', 'icon': Icons.shopping_cart, 'color': AppTheme.success},
  ];

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    try {
      final pos = await LocationService().getCurrentPosition();
      if (mounted && pos != null) {
        setState(() {
          _selectedLocation = pos;
          _loadingLocation = false;
        });
      } else if (mounted) {
        setState(() {
          _selectedLocation = const LatLng(20.5937, 78.9629); // India center fallback
          _loadingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _selectedLocation = const LatLng(20.5937, 78.9629); // India center fallback
          _loadingLocation = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Resource Location'),
        backgroundColor: AppTheme.background,
      ),
      body: BlocListener<MarkerBloc, MarkerState>(
        listener: (context, state) {
          if (state is MarkerAdded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Marker added successfully!'),
                backgroundColor: AppTheme.success,
              ),
            );
            context.pop();
          } else if (state is MarkerError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.danger,
              ),
            );
          }
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.background, AppTheme.surface],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Map (tap to place pin) ──
                  SizedBox(
                    height: 250,
                    child: _loadingLocation
                        ? const Center(
                            child: CircularProgressIndicator(color: AppTheme.primary),
                          )
                        : ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(20),
                            ),
                            child: FlutterMap(
                              mapController: _mapController,
                              options: MapOptions(
                                initialCenter: _selectedLocation!,
                                initialZoom: 15,
                                onTap: (tapPos, latLng) {
                                  setState(() => _selectedLocation = latLng);
                                },
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.disasterlink.app',
                                ),
                                if (_selectedLocation != null)
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        point: _selectedLocation!,
                                        width: 40,
                                        height: 40,
                                        child: const Icon(
                                          Icons.location_pin,
                                          color: AppTheme.primary,
                                          size: 40,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    child: Text(
                      'Tap the map to select location',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Marker Type Selector ──
                        const Text(
                          'Resource Type',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _markerTypes.map((type) {
                              final isSelected = _selectedType == type['key'];
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  avatar: Icon(
                                    type['icon'] as IconData,
                                    size: 18,
                                    color: isSelected
                                        ? type['color'] as Color
                                        : AppTheme.textSecondary,
                                  ),
                                  label: Text(type['label'] as String),
                                  selected: isSelected,
                                  selectedColor:
                                      (type['color'] as Color).withOpacity(0.2),
                                  backgroundColor: AppTheme.card,
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? type['color'] as Color
                                        : AppTheme.textSecondary,
                                  ),
                                  onSelected: (val) {
                                    if (val) {
                                      setState(() =>
                                          _selectedType = type['key'] as String);
                                    }
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ── Title ──
                        TextFormField(
                          controller: _titleCtrl,
                          style: const TextStyle(color: AppTheme.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Title',
                            hintText: 'e.g., Community Kitchen at Town Hall',
                            prefixIcon: const Icon(Icons.title,
                                color: AppTheme.textMuted),
                            filled: true,
                            fillColor: AppTheme.card,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Title is required'
                              : null,
                        ),
                        const SizedBox(height: 16),

                        // ── Description ──
                        TextFormField(
                          controller: _descCtrl,
                          maxLines: 2,
                          style: const TextStyle(color: AppTheme.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Description (optional)',
                            hintText: 'Opening hours, capacity, contact...',
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(bottom: 24),
                              child: Icon(Icons.notes,
                                  color: AppTheme.textMuted),
                            ),
                            filled: true,
                            fillColor: AppTheme.card,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // ── Save Button ──
                        BlocBuilder<MarkerBloc, MarkerState>(
                          builder: (context, state) {
                            final isLoading = state is MarkerAdding;
                            return SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton.icon(
                                icon: isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.add_location,
                                        color: Colors.white),
                                label: Text(
                                  isLoading ? 'Saving...' : 'Save Location',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.secondary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: isLoading || _selectedLocation == null
                                    ? null
                                    : () {
                                        if (_formKey.currentState
                                                ?.validate() ??
                                            false) {
                                          final marker = app_marker.MarkerModel(
                                            id: '',
                                            type: app_marker.MarkerType.values
                                                .firstWhere(
                                              (t) => t.name == _selectedType,
                                            ),
                                            location: _selectedLocation!,
                                            title: _titleCtrl.text.trim(),
                                            description:
                                                _descCtrl.text.trim(),
                                            createdBy: '',
                                            createdAt: DateTime.now(),
                                            isActive: true,
                                          );
                                          context.read<MarkerBloc>().add(
                                                MarkerAddRequested(marker),
                                              );
                                        }
                                      },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}