import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:disaster_link/app.dart';
import 'package:disaster_link/blocs/auth/auth_bloc.dart';
import 'package:disaster_link/blocs/connectivity/connectivity_bloc.dart';
import 'package:disaster_link/blocs/marker/marker_bloc.dart';
import 'package:disaster_link/blocs/help_request/help_request_bloc.dart';
import 'package:disaster_link/blocs/bluetooth/bluetooth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force dark status bar for immersive dark theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0A0E14),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // ── Initialize Supabase ──────────────────────────────────────────────────
  // TODO: Replace with your Supabase project URL and anon key
  // Get these from: Supabase Dashboard → Settings → API
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',       // e.g. https://xxxxx.supabase.co
    anonKey: 'YOUR_SUPABASE_ANON_KEY', // e.g. eyJhbGciOiJI...
  );

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc()..add(AuthCheckRequested()),
        ),
        BlocProvider<ConnectivityBloc>(
          create: (_) => ConnectivityBloc()..add(ConnectivityCheckRequested()),
        ),
        BlocProvider<MarkerBloc>(
          create: (_) => MarkerBloc(),
        ),
        BlocProvider<HelpRequestBloc>(
          create: (_) => HelpRequestBloc(),
        ),
        BlocProvider<BluetoothBloc>(
          create: (_) => BluetoothBloc(),
        ),
      ],
      child: const DisasterLinkApp(),
    ),
  );
}
