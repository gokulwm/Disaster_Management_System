import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:disaster_link/blocs/help_request/help_request_bloc.dart';
import 'package:disaster_link/data/services/location_service.dart';
import 'package:disaster_link/presentation/theme/app_theme.dart';
import 'package:disaster_link/presentation/widgets/request_card.dart';

class HelpRequestsScreen extends StatefulWidget {
  const HelpRequestsScreen({super.key});

  @override
  State<HelpRequestsScreen> createState() => _HelpRequestsScreenState();
}

class _HelpRequestsScreenState extends State<HelpRequestsScreen> {
  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    try {
      final position = await LocationService().getCurrentPosition();
      if (mounted) {
        if (position != null) {
          context.read<HelpRequestBloc>().add(
                HelpRequestsFetchRequested(position.latitude, position.longitude),
              );
        } else {
          context.read<HelpRequestBloc>().add(
                HelpRequestsFetchRequested(0, 0),
              );
        }
      }
    } catch (e) {
      if (mounted) {
        context.read<HelpRequestBloc>().add(
              HelpRequestsFetchRequested(0, 0),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Help Requests'),
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
            if (state is HelpRequestAccepted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Request accepted! Contact the person in need.'),
                  backgroundColor: AppTheme.success,
                ),
              );
              _fetchRequests();
            } else if (state is HelpRequestAlreadyTaken) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('This request was already accepted by another volunteer.'),
                  backgroundColor: AppTheme.secondary,
                ),
              );
              _fetchRequests();
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
                child: CircularProgressIndicator(color: AppTheme.primary),
              );
            }

            if (state is HelpRequestsLoaded) {
              if (state.requests.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline,
                          size: 80, color: AppTheme.success.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      const Text(
                        'No pending requests nearby',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Pull down to refresh',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: AppTheme.primary,
                onRefresh: () async => _fetchRequests(),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.requests.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final request = state.requests[index];
                    return RequestCard(
                      name: request.requesterName,
                      type: request.helpType.name,
                      distance: request.distMeters != null
                          ? '${(request.distMeters! / 1000).toStringAsFixed(1)} km'
                          : 'Unknown',
                      timeAgo: _timeAgo(request.createdAt),
                      onAccept: () {
                        _showAcceptDialog(context, request.id);
                      },
                    );
                  },
                ),
              );
            }

            if (state is HelpRequestError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: AppTheme.danger),
                    const SizedBox(height: 16),
                    Text(state.message, style: const TextStyle(color: AppTheme.textSecondary)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchRequests,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return const Center(
              child: Text('Fetching nearby requests...', style: TextStyle(color: AppTheme.textSecondary)),
            );
          },
        ),
      ),
    );
  }

  void _showAcceptDialog(BuildContext context, String requestId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Accept Request?', style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text(
          'You will be assigned to help this person. Are you sure?',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<HelpRequestBloc>().add(HelpRequestAcceptRequested(requestId));
            },
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime? dateTime) {
    if (dateTime == null) return 'unknown';
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}