import os

base = r"d:\Antigravity projects\Disaster_Management_system\lib"

files = {
    # BLOCS - AUTH
    "blocs/auth/auth_event.dart": """
part of 'auth_bloc.dart';
abstract class AuthEvent {}
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  AuthLoginRequested(this.email, this.password);
}
class AuthSignupRequested extends AuthEvent {
  final String email, password, fullName, phone;
  AuthSignupRequested(this.email, this.password, this.fullName, this.phone);
}
class AuthLogoutRequested extends AuthEvent {}
class AuthCheckRequested extends AuthEvent {}
""",
    "blocs/auth/auth_state.dart": """
part of 'auth_bloc.dart';
abstract class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final dynamic volunteerProfile;
  AuthAuthenticated(this.volunteerProfile);
}
class AuthUnverified extends AuthState {
  final dynamic volunteerProfile;
  AuthUnverified(this.volunteerProfile);
}
class AuthUnauthenticated extends AuthState {}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
""",
    "blocs/auth/auth_bloc.dart": """
import 'package:flutter_bloc/flutter_bloc.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AuthCheckRequested>((event, emit) async {
      emit(AuthLoading());
      await Future.delayed(const Duration(seconds: 1)); // Mock
      emit(AuthUnauthenticated());
    });
    
    on<AuthLoginRequested>((event, emit) async {
      emit(AuthLoading());
      await Future.delayed(const Duration(seconds: 2)); // Mock
      if(event.email.contains("unverified")) {
         emit(AuthUnverified({"name": "Test"}));
      } else {
         emit(AuthAuthenticated({"name": "Test", "role": "volunteer"}));
      }
    });

    on<AuthSignupRequested>((event, emit) async {
      emit(AuthLoading());
      await Future.delayed(const Duration(seconds: 2));
      emit(AuthUnverified({"name": event.fullName}));
    });

    on<AuthLogoutRequested>((event, emit) {
      emit(AuthUnauthenticated());
    });
  }
}
""",
    
    # BLOCS - CONNECTIVITY
    "blocs/connectivity/connectivity_event.dart": """
part of 'connectivity_bloc.dart';
abstract class ConnectivityEvent {}
class ConnectivityChanged extends ConnectivityEvent {
  final ConnectivityStatus status;
  ConnectivityChanged(this.status);
}
class ConnectivityCheckRequested extends ConnectivityEvent {}
""",
    "blocs/connectivity/connectivity_state.dart": """
part of 'connectivity_bloc.dart';
enum ConnectivityStatus { online, poor, offline, btMode }
class ConnectivityState {
  final ConnectivityStatus status;
  ConnectivityState(this.status);
}
""",
    "blocs/connectivity/connectivity_bloc.dart": """
import 'package:flutter_bloc/flutter_bloc.dart';
part 'connectivity_event.dart';
part 'connectivity_state.dart';

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  ConnectivityBloc() : super(ConnectivityState(ConnectivityStatus.online)) {
    on<ConnectivityChanged>((event, emit) {
      emit(ConnectivityState(event.status));
    });
    on<ConnectivityCheckRequested>((event, emit) {
      emit(ConnectivityState(ConnectivityStatus.online));
    });
  }
}
""",

    # BLOCS - MARKER
    "blocs/marker/marker_event.dart": """
part of 'marker_bloc.dart';
abstract class MarkerEvent {}
class MarkersFetchRequested extends MarkerEvent {
  final double lat, lng;
  MarkersFetchRequested(this.lat, this.lng);
}
class MarkerAddRequested extends MarkerEvent {
  final dynamic marker;
  MarkerAddRequested(this.marker);
}
class MarkersSubscribeRequested extends MarkerEvent {}
""",
    "blocs/marker/marker_state.dart": """
part of 'marker_bloc.dart';
abstract class MarkerState {}
class MarkerInitial extends MarkerState {}
class MarkerLoading extends MarkerState {}
class MarkerLoaded extends MarkerState {
  final List<dynamic> markers;
  MarkerLoaded(this.markers);
}
class MarkerAdding extends MarkerState {}
class MarkerAdded extends MarkerState {}
class MarkerError extends MarkerState {
  final String message;
  MarkerError(this.message);
}
""",
    "blocs/marker/marker_bloc.dart": """
import 'package:flutter_bloc/flutter_bloc.dart';
part 'marker_event.dart';
part 'marker_state.dart';

class MarkerBloc extends Bloc<MarkerEvent, MarkerState> {
  MarkerBloc() : super(MarkerInitial()) {
    on<MarkersFetchRequested>((event, emit) async {
      emit(MarkerLoading());
      await Future.delayed(const Duration(seconds: 1));
      emit(MarkerLoaded([]));
    });
    on<MarkerAddRequested>((event, emit) async {
      emit(MarkerAdding());
      await Future.delayed(const Duration(seconds: 1));
      emit(MarkerAdded());
      add(MarkersFetchRequested(0, 0));
    });
    on<MarkersSubscribeRequested>((event, emit) {});
  }
}
""",

    # BLOCS - HELP REQUEST
    "blocs/help_request/help_request_event.dart": """
part of 'help_request_bloc.dart';
abstract class HelpRequestEvent {}
class HelpRequestSubmitRequested extends HelpRequestEvent {
  final String name, helpType, description;
  final double lat, lng;
  HelpRequestSubmitRequested(this.name, this.helpType, this.lat, this.lng, this.description);
}
class HelpRequestStatusRequested extends HelpRequestEvent {
  final String token;
  HelpRequestStatusRequested(this.token);
}
class HelpRequestAcceptRequested extends HelpRequestEvent {
  final String requestId;
  HelpRequestAcceptRequested(this.requestId);
}
class HelpRequestsFetchRequested extends HelpRequestEvent {
  final double lat, lng;
  HelpRequestsFetchRequested(this.lat, this.lng);
}
class HelpRequestsSubscribeRequested extends HelpRequestEvent {}
""",
    "blocs/help_request/help_request_state.dart": """
part of 'help_request_bloc.dart';
abstract class HelpRequestState {}
class HelpRequestInitial extends HelpRequestState {}
class HelpRequestLoading extends HelpRequestState {}
class HelpRequestSubmitted extends HelpRequestState {
  final String requestToken;
  HelpRequestSubmitted(this.requestToken);
}
class HelpRequestStatusLoaded extends HelpRequestState {
  final dynamic detail;
  HelpRequestStatusLoaded(this.detail);
}
class HelpRequestsLoaded extends HelpRequestState {
  final List<dynamic> requests;
  HelpRequestsLoaded(this.requests);
}
class HelpRequestAccepting extends HelpRequestState {}
class HelpRequestAccepted extends HelpRequestState {}
class HelpRequestError extends HelpRequestState {
  final String message;
  HelpRequestError(this.message);
}
""",
    "blocs/help_request/help_request_bloc.dart": """
import 'package:flutter_bloc/flutter_bloc.dart';
part 'help_request_event.dart';
part 'help_request_state.dart';

class HelpRequestBloc extends Bloc<HelpRequestEvent, HelpRequestState> {
  HelpRequestBloc() : super(HelpRequestInitial()) {
    on<HelpRequestSubmitRequested>((event, emit) async {
      emit(HelpRequestLoading());
      await Future.delayed(const Duration(seconds: 2));
      emit(HelpRequestSubmitted("REQ-12345"));
    });
    on<HelpRequestStatusRequested>((event, emit) async {
      emit(HelpRequestLoading());
      await Future.delayed(const Duration(seconds: 1));
      emit(HelpRequestStatusLoaded({"status": "Accepted", "volunteer": "John Doe"}));
    });
    on<HelpRequestsFetchRequested>((event, emit) async {
      emit(HelpRequestLoading());
      await Future.delayed(const Duration(seconds: 1));
      emit(HelpRequestsLoaded([]));
    });
    on<HelpRequestAcceptRequested>((event, emit) async {
      emit(HelpRequestAccepting());
      await Future.delayed(const Duration(seconds: 1));
      emit(HelpRequestAccepted());
    });
  }
}
""",

    # BLOCS - BLUETOOTH
    "blocs/bluetooth/bluetooth_event.dart": """
part of 'bluetooth_bloc.dart';
abstract class BluetoothEvent {}
class BluetoothStartRequested extends BluetoothEvent {}
class BluetoothStopRequested extends BluetoothEvent {}
class BluetoothPayloadReceived extends BluetoothEvent {
  final List<int> bytes;
  BluetoothPayloadReceived(this.bytes);
}
""",
    "blocs/bluetooth/bluetooth_state.dart": """
part of 'bluetooth_bloc.dart';
abstract class BluetoothState {}
class BluetoothInitial extends BluetoothState {}
class BluetoothDiscovering extends BluetoothState {
  final List<dynamic> devicesFound;
  BluetoothDiscovering(this.devicesFound);
}
class BluetoothRelaying extends BluetoothState {}
class BluetoothSyncing extends BluetoothState {}
class BluetoothError extends BluetoothState {
  final String message;
  BluetoothError(this.message);
}
""",
    "blocs/bluetooth/bluetooth_bloc.dart": """
import 'package:flutter_bloc/flutter_bloc.dart';
part 'bluetooth_event.dart';
part 'bluetooth_state.dart';

class BluetoothBloc extends Bloc<BluetoothEvent, BluetoothState> {
  BluetoothBloc() : super(BluetoothInitial()) {
    on<BluetoothStartRequested>((event, emit) async {
      emit(BluetoothDiscovering([]));
    });
    on<BluetoothStopRequested>((event, emit) {
      emit(BluetoothInitial());
    });
    on<BluetoothPayloadReceived>((event, emit) {
      emit(BluetoothSyncing());
    });
  }
}
""",

    # UI - APP THEME & CONSTANTS (Helper)
    "presentation/theme/app_theme.dart": """
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFF0A0E14);
  static const Color surface = Color(0xFF1A1F2B);
  static const Color card = Color(0xFF242B3A);
  static const Color primary = Color(0xFFFF3D3D);
  static const Color secondary = Color(0xFFFFB300);
  static const Color success = Color(0xFF00E676);
  static const Color danger = Color(0xFFFF1744);
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFF9E9E9E);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: danger,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        bodyLarge: const TextStyle(color: textPrimary),
        bodyMedium: const TextStyle(color: textSecondary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
""",

    # UI - HOME
    "presentation/home/connectivity_banner.dart": """
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
""",
    "presentation/home/home_screen.dart": """
import 'package:flutter/material.dart';
import 'package:disaster_link/presentation/theme/app_theme.dart';
import 'connectivity_banner.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ConnectivityBanner(),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.background, AppTheme.surface],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 80, color: AppTheme.primary),
                      const SizedBox(height: 16),
                      Text(
                        'DisasterLink',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Connecting help when it matters most',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 60),
                      _RoleCard(
                        title: '🙋 I Need Help',
                        gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.danger]),
                        onTap: () => Navigator.pushNamed(context, '/seeker_home'),
                      ),
                      const SizedBox(height: 24),
                      _RoleCard(
                        title: "🦺 I'm a Volunteer",
                        gradient: const LinearGradient(colors: [AppTheme.secondary, Colors.orangeAccent]),
                        onTap: () => Navigator.pushNamed(context, '/login'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatefulWidget {
  final String title;
  final Gradient gradient;
  final VoidCallback onTap;

  const _RoleCard({required this.title, required this.gradient, required this.onTap});

  @override
  __RoleCardState createState() => __RoleCardState();
}

class __RoleCardState extends State<_RoleCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.gradient.colors.first.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
""",

    # UI - AUTH
    "presentation/auth/login_screen.dart": """
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import 'package:disaster_link/blocs/auth/auth_bloc.dart';
import 'package:disaster_link/presentation/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.pushReplacementNamed(context, '/volunteer_home');
          } else if (state is AuthUnverified) {
            Navigator.pushReplacementNamed(context, '/pending_verification');
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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppTheme.card.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) => Transform.scale(
                            scale: 1.0 + (_pulseController.value * 0.05),
                            child: const Icon(Icons.shield, size: 60, color: AppTheme.primary),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Volunteer Login',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _emailCtrl,
                          style: const TextStyle(color: AppTheme.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Email',
                            filled: true,
                            fillColor: AppTheme.surface.withOpacity(0.8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passCtrl,
                          obscureText: true,
                          style: const TextStyle(color: AppTheme.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            filled: true,
                            fillColor: AppTheme.surface.withOpacity(0.8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 32),
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            return SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: state is AuthLoading
                                    ? null
                                    : () {
                                        context.read<AuthBloc>().add(AuthLoginRequested(_emailCtrl.text, _passCtrl.text));
                                      },
                                child: state is AuthLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/signup'),
                          child: const Text("Don't have an account? Sign Up", style: TextStyle(color: AppTheme.secondary)),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
""",
    "presentation/auth/signup_screen.dart": """
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import 'package:disaster_link/blocs/auth/auth_bloc.dart';
import 'package:disaster_link/presentation/theme/app_theme.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnverified) {
            Navigator.pushReplacementNamed(context, '/pending_verification');
          }
        },
        child: Container(
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.background, AppTheme.surface],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppTheme.card.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Create Volunteer Account',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        _buildField(nameCtrl, 'Full Name'),
                        const SizedBox(height: 16),
                        _buildField(emailCtrl, 'Email'),
                        const SizedBox(height: 16),
                        _buildField(phoneCtrl, 'Phone Number'),
                        const SizedBox(height: 16),
                        _buildField(passCtrl, 'Password', obscure: true),
                        const SizedBox(height: 32),
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            return SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.secondary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: state is AuthLoading
                                    ? null
                                    : () {
                                        context.read<AuthBloc>().add(AuthSignupRequested(
                                          emailCtrl.text, passCtrl.text, nameCtrl.text, phoneCtrl.text
                                        ));
                                      },
                                child: state is AuthLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text('Sign Up', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Back to Login", style: TextStyle(color: AppTheme.textSecondary)),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, {bool obscure = false}) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppTheme.surface.withOpacity(0.8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}
""",
    "presentation/auth/pending_verification_screen.dart": """
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:disaster_link/blocs/auth/auth_bloc.dart';
import 'package:disaster_link/presentation/theme/app_theme.dart';

class PendingVerificationScreen extends StatelessWidget {
  const PendingVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.background, AppTheme.surface],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.hourglass_empty, size: 80, color: AppTheme.secondary),
              const SizedBox(height: 32),
              const Text(
                'Verification Pending',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your account is pending admin verification. You will be able to access volunteer features once verified.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Check Status'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  context.read<AuthBloc>().add(AuthCheckRequested());
                },
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(AuthLogoutRequested());
                  Navigator.pushReplacementNamed(context, '/');
                },
                child: const Text('Logout', style: TextStyle(color: AppTheme.textSecondary)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
""",

    # UI - SEEKER
    "presentation/seeker/seeker_home_screen.dart": """
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:disaster_link/presentation/theme/app_theme.dart';
import 'package:disaster_link/presentation/home/connectivity_banner.dart';

class SeekerHomeScreen extends StatelessWidget {
  const SeekerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const ConnectivityBanner(),
        toolbarHeight: 40,
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: const LatLng(0, 0),
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://cartodb-basemaps-{s}.global.ssl.fastly.net/dark_all/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
            ],
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 10,
                shadowColor: AppTheme.primary.withOpacity(0.5),
              ),
              onPressed: () => Navigator.pushNamed(context, '/raise_request'),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sos, color: Colors.white, size: 28),
                  SizedBox(width: 8),
                  Text('Raise Help Request', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
""",
    "presentation/seeker/raise_request_screen.dart": """
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:disaster_link/blocs/help_request/help_request_bloc.dart';
import 'package:disaster_link/presentation/theme/app_theme.dart';

class RaiseRequestScreen extends StatelessWidget {
  const RaiseRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String selectedType = 'Medical';

    return Scaffold(
      appBar: AppBar(title: const Text('Request Help')),
      body: BlocConsumer<HelpRequestBloc, HelpRequestState>(
        listener: (context, state) {
          if (state is HelpRequestSubmitted) {
            Navigator.pushReplacementNamed(context, '/request_status', arguments: state.requestToken);
          }
        },
        builder: (context, state) {
          if (state is HelpRequestLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('What kind of help do you need?', style: TextStyle(fontSize: 18, color: AppTheme.textPrimary)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: ['Medical', 'Food', 'Shelter', 'Rescue'].map((type) {
                    return ChoiceChip(
                      label: Text(type),
                      selected: selectedType == type,
                      selectedColor: AppTheme.primary.withOpacity(0.3),
                      backgroundColor: AppTheme.card,
                      labelStyle: TextStyle(color: selectedType == type ? AppTheme.primary : AppTheme.textSecondary),
                      onSelected: (val) {},
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: nameCtrl,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Your Name (Optional)',
                    filled: true,
                    fillColor: AppTheme.card,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descCtrl,
                  maxLines: 3,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Additional Details',
                    filled: true,
                    fillColor: AppTheme.card,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      context.read<HelpRequestBloc>().add(HelpRequestSubmitRequested(nameCtrl.text, selectedType, 0, 0, descCtrl.text));
                    },
                    child: const Text('Submit Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
""",
    "presentation/seeker/request_status_screen.dart": """
import 'package:flutter/material.dart';
import 'package:disaster_link/presentation/theme/app_theme.dart';

class RequestStatusScreen extends StatelessWidget {
  const RequestStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Status')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.check_circle_outline, size: 80, color: AppTheme.success),
            const SizedBox(height: 16),
            const Text('Request Received', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            const Text('Token: REQ-12345', style: TextStyle(fontSize: 16, color: AppTheme.secondary)),
            const SizedBox(height: 40),
            _buildTimelineStep('Submitted', true, true),
            _buildTimelineStep('Volunteer Accepted', false, false),
            _buildTimelineStep('Resolved', false, false, isLast: true),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStep(String title, bool isActive, bool isCompleted, {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted ? AppTheme.success : (isActive ? AppTheme.secondary : AppTheme.card),
                shape: BoxShape.circle,
              ),
              child: isCompleted ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
            ),
            if (!isLast)
              Container(width: 2, height: 40, color: isCompleted ? AppTheme.success : AppTheme.card),
          ],
        ),
        const SizedBox(width: 16),
        Text(title, style: TextStyle(fontSize: 18, color: isActive || isCompleted ? AppTheme.textPrimary : AppTheme.textSecondary)),
      ],
    );
  }
}
""",
    "presentation/seeker/map_view_screen.dart": """
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:disaster_link/presentation/theme/app_theme.dart';

class MapViewScreen extends StatelessWidget {
  const MapViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Map')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: const LatLng(0, 0),
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://cartodb-basemaps-{s}.global.ssl.fastly.net/dark_all/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
        ],
      ),
    );
  }
}
""",

    # UI - VOLUNTEER
    "presentation/volunteer/volunteer_home_screen.dart": """
import 'package:flutter/material.dart';
import 'package:disaster_link/presentation/theme/app_theme.dart';
import 'package:disaster_link/presentation/home/connectivity_banner.dart';

class VolunteerHomeScreen extends StatelessWidget {
  const VolunteerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Volunteer Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {},
          )
        ],
      ),
      body: Column(
        children: [
          const ConnectivityBanner(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  children: [
                    Expanded(child: _StatCard(title: 'Pending', count: '12', color: AppTheme.secondary)),
                    const SizedBox(width: 16),
                    Expanded(child: _StatCard(title: 'Accepted', count: '4', color: AppTheme.success)),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                const SizedBox(height: 16),
                _ActionTile(icon: Icons.list_alt, title: 'View Help Requests', onTap: () => Navigator.pushNamed(context, '/help_requests')),
                const SizedBox(height: 12),
                _ActionTile(icon: Icons.add_location_alt, title: 'Add Resource Marker', onTap: () => Navigator.pushNamed(context, '/add_marker')),
                const SizedBox(height: 12),
                _ActionTile(icon: Icons.map, title: 'Open Full Map', onTap: () => Navigator.pushNamed(context, '/volunteer_map')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String count;
  final Color color;
  const _StatCard({required this.title, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border(bottom: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        children: [
          Text(count, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _ActionTile({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: AppTheme.card,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: AppTheme.textPrimary),
      ),
      title: Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textSecondary),
    );
  }
}
""",
    "presentation/volunteer/help_requests_screen.dart": """
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:disaster_link/blocs/help_request/help_request_bloc.dart';
import 'package:disaster_link/presentation/theme/app_theme.dart';
import 'package:disaster_link/presentation/widgets/request_card.dart';

class HelpRequestsScreen extends StatelessWidget {
  const HelpRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Requests')),
      body: BlocBuilder<HelpRequestBloc, HelpRequestState>(
        builder: (context, state) {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: 5,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return RequestCard(
                name: 'Anonymous',
                type: 'Medical',
                distance: '2.4 km',
                timeAgo: '10 min ago',
                onAccept: () {},
              );
            },
          );
        },
      ),
    );
  }
}
""",
    "presentation/volunteer/add_marker_screen.dart": """
import 'package:flutter/material.dart';
import 'package:disaster_link/presentation/theme/app_theme.dart';

class AddMarkerScreen extends StatelessWidget {
  const AddMarkerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Resource')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(child: Text('Map View Placeholder', style: TextStyle(color: AppTheme.textSecondary))),
            ),
            const SizedBox(height: 24),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Title',
                filled: true,
                fillColor: AppTheme.card,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Save Marker', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
""",
    "presentation/volunteer/volunteer_map_screen.dart": """
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:disaster_link/presentation/theme/app_theme.dart';

class VolunteerMapScreen extends StatelessWidget {
  const VolunteerMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Volunteer Map')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: const LatLng(0, 0),
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://cartodb-basemaps-{s}.global.ssl.fastly.net/dark_all/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
        ],
      ),
    );
  }
}
""",

    # UI - WIDGETS
    "presentation/widgets/request_card.dart": """
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:disaster_link/presentation/theme/app_theme.dart';

class RequestCard extends StatelessWidget {
  final String name;
  final String type;
  final String distance;
  final String timeAgo;
  final VoidCallback onAccept;

  const RequestCard({super.key, required this.name, required this.type, required this.distance, required this.timeAgo, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.card.withOpacity(0.7),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppTheme.danger.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.medical_services, color: AppTheme.danger),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontSize: 16)),
                        Text('$type • $distance', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                      ],
                    ),
                  ),
                  Text(timeAgo, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: onAccept,
                  child: const Text('Accept Request', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
""",
    "presentation/widgets/marker_card.dart": """
import 'package:flutter/material.dart';
import 'package:disaster_link/presentation/theme/app_theme.dart';

class MarkerCard extends StatelessWidget {
  final String title;
  final String description;
  const MarkerCard({super.key, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          Text(description, style: const TextStyle(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}
""",
    "presentation/widgets/connectivity_indicator.dart": """
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
""",
    "presentation/widgets/map_marker_layer.dart": """
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:disaster_link/presentation/theme/app_theme.dart';

class MapMarkerLayer extends StatelessWidget {
  const MapMarkerLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return MarkerLayer(
      markers: [
        Marker(
          point: const LatLng(0, 0),
          width: 40,
          height: 40,
          child: const Icon(Icons.location_on, color: AppTheme.primary, size: 40),
        ),
      ],
    );
  }
}
"""
}

for path, content in files.items():
    full_path = os.path.join(base, path.replace('/', os.sep))
    os.makedirs(os.path.dirname(full_path), exist_ok=True)
    with open(full_path, "w", encoding="utf-8") as f:
        f.write(content.strip() + r"\n")
print("Files generated successfully!")
