import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:disaster_link/blocs/connectivity/connectivity_bloc.dart';
import 'package:disaster_link/presentation/theme/app_theme.dart';

class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityBloc, ConnectivityState>(
      builder: (context, state) {
        Color bgColor;
        String text;
        IconData icon;
        
        switch (state.status) {
          case ConnectivityStatus.online:
            bgColor = AppTheme.success;
            text = 'Connected';
            icon = Icons.wifi;
            break;
          case ConnectivityStatus.btMode:
            bgColor = Colors.blueAccent;
            text = 'Bluetooth Mode';
            icon = Icons.bluetooth;
            break;
          case ConnectivityStatus.offline:
          case ConnectivityStatus.poor:
            bgColor = AppTheme.danger;
            text = 'Offline';
            icon = Icons.wifi_off;
            break;
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          height: 30,
          color: bgColor.withOpacity(0.9),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
