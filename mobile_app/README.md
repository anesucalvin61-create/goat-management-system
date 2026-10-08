# Goat Management Mobile App

This project is a Flutter-based goat management mobile app built with Supabase for authentication, database storage, and reporting.

## Stack
- Flutter
- Supabase
- PDF export with `pdf` and `printing`

## Features
- User login and signup
- Goat registration and editing
- Vaccination tracking
- Herd size summaries
- Report generation and PDF export
- Mobile-first layout
- Ready for Supabase database integration

## Project structure
- `mobile_app/lib` — Flutter app source
- `mobile_app/supabase/schema.sql` — database schema for Supabase
- `mobile_app/pubspec.yaml` — app dependencies

## Setup
1. Create a Supabase project.
2. Run the SQL in `mobile_app/supabase/schema.sql` inside the Supabase SQL editor.
3. Update the `SUPABASE_URL` and `SUPABASE_ANON_KEY` values in your runtime environment or app config.
4. In Flutter, run:

```bash
cd mobile_app
flutter pub get
flutter run
```

## Important configuration
The app uses the following environment values:

```bash
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

You can pass them via build arguments or a .env file if you later add dotenv support.

## Notes
This is the foundation for a professional mobile app. It can be extended by adding:
- photo upload to Supabase Storage
- real-time herd updates
- owner dashboards
- scheduled vaccination reminders
- offline support
