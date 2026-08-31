import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:disaster_link/blocs/connectivity/connectivity_bloc.dart';
import 'package:disaster_link/presentation/theme/app_theme.dart';

class ConnectivityIndicator extends StatelessWidget {
  const ConnectivityIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityBloc, ConnectivityState>(
      builder: (context, state) {
        Color color = AppTheme.success;
        if (state.status == ConnectivityStatus.offline) color = AppTheme.danger;
        if (state.status == ConnectivityStatus.btMode) color = Colors.blue;
        
        return Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.5), blurRadius: 4, spreadRadius: 1)
            ],
          ),
        );
      },
    );
  }
}
