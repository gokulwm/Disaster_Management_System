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
    url: 'https://cuewgrwhqhceqxsqzmly.supabase.co',       // e.g. https://xxxxx.supabase.co
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN1ZXdncndocWhjZXF4c3F6bWx5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODgxOTI4NDAsImV4cCI6MjEwMzc2ODg0MH0.u9BaXD4O69KZrs30DYsgdkCnWW7Eb9MEFDY0qJ5QGeQ', // e.g. eyJhbGciOiJI...
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
