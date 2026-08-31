import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Auth screens
import 'package:disaster_link/presentation/auth/login_screen.dart';
import 'package:disaster_link/presentation/auth/signup_screen.dart';
import 'package:disaster_link/presentation/auth/pending_verification_screen.dart';

// Home
import 'package:disaster_link/presentation/home/home_screen.dart';

// Seeker screens
import 'package:disaster_link/presentation/seeker/seeker_home_screen.dart';
import 'package:disaster_link/presentation/seeker/raise_request_screen.dart';
import 'package:disaster_link/presentation/seeker/request_status_screen.dart';
import 'package:disaster_link/presentation/seeker/map_view_screen.dart';

// Volunteer screens
import 'package:disaster_link/presentation/volunteer/volunteer_home_screen.dart';
import 'package:disaster_link/presentation/volunteer/help_requests_screen.dart';
import 'package:disaster_link/presentation/volunteer/add_marker_screen.dart';
import 'package:disaster_link/presentation/volunteer/volunteer_map_screen.dart';

/// Global navigator key for GoRouter
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Application router configuration.
///
/// Routes:
///   / → Splash / Role Selection (HomeScreen)
///   /login → Volunteer Login
///   /signup → Volunteer Signup
///   /pending-verification → Awaiting admin verification
///   /seeker → Help Seeker Home (Map)
///   /seeker/raise-request → Submit help request
///   /seeker/request-status → Track request via token
///   /seeker/map → Full map view
///   /volunteer → Volunteer Dashboard
///   /volunteer/requests → Help requests feed
///   /volunteer/add-marker → Add food/shelter/danger/medical/grocery
///   /volunteer/map → Volunteer full map
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    // ── Role Selection / Splash ────────────────────────────────────────
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),

    // ── Auth Routes ───────────────────────────────────────────────────
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: '/pending-verification',
      name: 'pending-verification',
      builder: (context, state) => const PendingVerificationScreen(),
    ),

    // ── Seeker Routes ─────────────────────────────────────────────────
    GoRoute(
      path: '/seeker',
      name: 'seeker',
      builder: (context, state) => const SeekerHomeScreen(),
      routes: [
        GoRoute(
          path: 'raise-request',
          name: 'raise-request',
          builder: (context, state) => const RaiseRequestScreen(),
        ),
        GoRoute(
          path: 'request-status',
          name: 'request-status',
          builder: (context, state) => const RequestStatusScreen(),
        ),
        GoRoute(
          path: 'map',
          name: 'seeker-map',
          builder: (context, state) => const MapViewScreen(),
        ),
      ],
    ),

    // ── Volunteer Routes ──────────────────────────────────────────────
    GoRoute(
      path: '/volunteer',
      name: 'volunteer',
      builder: (context, state) => const VolunteerHomeScreen(),
      routes: [
        GoRoute(
          path: 'requests',
          name: 'volunteer-requests',
          builder: (context, state) => const HelpRequestsScreen(),
        ),
        GoRoute(
          path: 'add-marker',
          name: 'add-marker',
          builder: (context, state) => const AddMarkerScreen(),
        ),
        GoRoute(
          path: 'map',
          name: 'volunteer-map',
          builder: (context, state) => const VolunteerMapScreen(),
        ),
      ],
    ),
  ],
);
