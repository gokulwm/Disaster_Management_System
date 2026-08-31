# 🆘 DisasterLink

**Help When It Matters Most**

A hybrid mobile application that connects disaster-affected people with verified volunteers. Works online via Supabase and offline via Bluetooth peer-to-peer relay.

## Features

### 👤 Help Seekers (No Login Required)
- Raise a help request (food, medical, rescue, shelter)
- View nearby shelters, food distribution points, medical & grocery shops
- Track request status via device-generated token

### 🦺 Volunteers (Login Required, Admin Verified)
- Upload resource locations (food, shelter, danger zones, shops)
- View and accept nearby help requests
- See incoming requests with distance, name, and help type

### 🔵 Offline Bluetooth Relay
- Data hops between devices via BLE when internet is unavailable
- Multi-hop relay with flood prevention (max 8 hops)
- Loop prevention, deduplication, and stale-state rejection
- Auto-syncs to Supabase when internet returns

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| Backend | Supabase (PostgreSQL + Auth + Realtime) |
| Geospatial | PostGIS (ST_DWithin, geography type) |
| Maps | flutter_map + OpenStreetMap |
| Bluetooth | flutter_nearby_connections |
| State | flutter_bloc |
| Local DB | sqflite (SQLite) |

## Getting Started

### Prerequisites
- Flutter SDK 3.22+
- Android Studio / Xcode
- A Supabase project (free tier works)

### Setup

1. **Clone the repository**
   ```bash
   git clone <repo-url>
   cd Disaster_Management_system
   ```

2. **Set up Supabase**
   - Create a project at [supabase.com](https://supabase.com)
   - Run the SQL from `supabase_schema.sql` in the SQL Editor
   - Copy your Project URL and anon key

3. **Configure the app**
   - Open `lib/main.dart`
   - Replace `YOUR_SUPABASE_URL` and `YOUR_SUPABASE_ANON_KEY` with your values

4. **Install dependencies**
   ```bash
   flutter pub get
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                    # Entry point + Supabase init
├── app.dart                     # MaterialApp.router + theme
├── core/                        # Constants, theme, router, utils
├── data/
│   ├── models/                  # Data models (Equatable)
│   ├── repositories/            # Online/offline data abstraction
│   ├── datasources/             # Supabase, SQLite, Bluetooth
│   └── services/                # Connectivity, location, encryption
├── presentation/
│   ├── auth/                    # Login, signup, verification
│   ├── home/                    # Role selection, connectivity banner
│   ├── seeker/                  # Map, raise request, status
│   ├── volunteer/               # Dashboard, requests feed, markers
│   └── widgets/                 # Shared reusable widgets
└── blocs/                       # Auth, connectivity, marker, request, BT
```

## Security Notes

- **BT Encryption**: AES-256 with an embedded key (best-effort obfuscation, not cryptographic security)
- **RLS**: Row Level Security on all tables; sensitive data in separate `help_request_private` table
- **Volunteer Vetting**: Admin manually verifies volunteers via Supabase dashboard
- **Rate Limiting**: 1 active help request per device (enforced via DB trigger)

## License

This project is for educational and portfolio purposes.
