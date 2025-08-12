## QuickBite Lite
Minimal Flutter + Supabase demo (web/mobile) that fetches menu items and supports search, category filter, sort (name/price), favorites (local), cart with total & checkout dialog, and light/dark theme toggle.

### Stack
Flutter + supabase_flutter + cached_network_image (state via setState).

### Supabase Table (menu_items)
id int PK | name text | price numeric | image_url text | category text

### Setup
1. Create Supabase project & table above; add some rows with public image URLs.
2. (If RLS on) add SELECT policy USING (true) for anon role.
3. Put your Supabase URL & anon key in `lib/main.dart`.
4. Install deps & run:
```bash
flutter pub get
flutter run -d chrome
```

### Build Web
```bash
flutter build web
```

Learning project; no auth or persistence yet.