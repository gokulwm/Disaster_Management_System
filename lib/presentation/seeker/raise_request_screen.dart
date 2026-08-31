import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:disaster_link/blocs/help_request/help_request_bloc.dart';
import 'package:disaster_link/data/services/location_service.dart';
import 'package:disaster_link/presentation/theme/app_theme.dart';

class RaiseRequestScreen extends StatefulWidget {
  const RaiseRequestScreen({super.key});

  @override
  State<RaiseRequestScreen> createState() => _RaiseRequestScreenState();
}

class _RaiseRequestScreenState extends State<RaiseRequestScreen> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedType = 'medical';
  double? _lat;
  double? _lng;
  bool _loadingLocation = true;

  final List<Map<String, dynamic>> _helpTypes = [
    {'key': 'medical', 'label': 'Medical', 'icon': Icons.local_hospital},
    {'key': 'food', 'label': 'Food', 'icon': Icons.restaurant},
    {'key': 'shelter', 'label': 'Shelter', 'icon': Icons.home},
    {'key': 'rescue', 'label': 'Rescue', 'icon': Icons.sos},
    {'key': 'other', 'label': 'Other', 'icon': Icons.help_outline},
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
          _lat = pos.latitude;
          _lng = pos.longitude;
          _loadingLocation = false;
        });
      } else if (mounted) {
        setState(() => _loadingLocation = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingLocation = false);
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Help'),
        backgroundColor: AppTheme.background,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.background, AppTheme.surface],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: BlocConsumer<HelpRequestBloc, HelpRequestState>(
          listener: (context, state) {
            if (state is HelpRequestSubmitted) {
              context.go('/seeker/request-status');
            } else if (state is HelpRequestError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppTheme.danger,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is HelpRequestLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppTheme.primary),
                    SizedBox(height: 16),
                    Text('Submitting your request...',
                        style: TextStyle(color: AppTheme.textSecondary)),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Location Status ──
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.card.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _loadingLocation
                                ? Icons.gps_not_fixed
                                : (_lat != null ? Icons.gps_fixed : Icons.gps_off),
                            color: _lat != null
                                ? AppTheme.success
                                : AppTheme.secondary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _loadingLocation
                                ? 'Detecting your location...'
                                : (_lat != null
                                    ? 'Location detected ✓'
                                    : 'Could not detect location'),
                            style: TextStyle(
                              color: _lat != null
                                  ? AppTheme.success
                                  : AppTheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Help Type ──
                    const Text(
                      'What kind of help do you need?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _helpTypes.map((type) {
                        final isSelected = _selectedType == type['key'];
                        return ChoiceChip(
                          avatar: Icon(
                            type['icon'] as IconData,
                            size: 18,
                            color: isSelected
                                ? AppTheme.primary
                                : AppTheme.textSecondary,
                          ),
                          label: Text(type['label'] as String),
                          selected: isSelected,
                          selectedColor: AppTheme.primary.withOpacity(0.2),
                          backgroundColor: AppTheme.card,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? AppTheme.primary
                                : AppTheme.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          onSelected: (val) {
                            if (val) {
                              setState(() => _selectedType = type['key'] as String);
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // ── Name ──
                    TextFormField(
                      controller: _nameCtrl,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Your Name',
                        hintText: 'So volunteers can identify you',
                        prefixIcon: const Icon(Icons.person_outline,
                            color: AppTheme.textMuted),
                        filled: true,
                        fillColor: AppTheme.card,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
                    ),
                    const SizedBox(height: 16),

                    // ── Description ──
                    TextFormField(
                      controller: _descCtrl,
                      maxLines: 3,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Describe your situation',
                        hintText: 'What help do you need? Any details?',
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 48),
                          child: Icon(Icons.description_outlined,
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

                    // ── Submit Button ──
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.send, color: Colors.white),
                        label: const Text(
                          'Submit Request',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 4,
                        ),
                        onPressed: (_lat == null)
                            ? null
                            : () {
                                if (_formKey.currentState?.validate() ?? false) {
                                  context.read<HelpRequestBloc>().add(
                                        HelpRequestSubmitRequested(
                                          _nameCtrl.text.trim(),
                                          _selectedType,
                                          _lat!,
                                          _lng!,
                                          _descCtrl.text.trim(),
                                        ),
                                      );
                                }
                              },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}