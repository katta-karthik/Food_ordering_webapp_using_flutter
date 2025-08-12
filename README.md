# QuickBite Lite

Minimal learning project: a Flutter + Supabase food menu with search, filters, sorting, favorites, cart & dark mode.

</div>

---

## ✨ Features
* Fetch menu items from Supabase (read‑only)
* Search & category filter (Veg / Non‑Veg / Drinks / Snacks)
* Sort by name or price (popup menu)
* Favorites (stored in memory this session)
* Cart with quantity control, total price, clear & checkout dialog
* Light / Dark theme toggle

## 🧱 Tech Stack
| Layer | Tools |
|-------|-------|
| UI | Flutter (Material3, setState) |
| Data | Supabase (REST via `supabase_flutter`) |
| Images | Network + `cached_network_image` |

## 🗄️ Table Schema: `menu_items`
| Column | Type | Notes |
|--------|------|-------|
| id | int (PK) | identity / primary key |
| name | text | item name |
| price | numeric | item price |
| image_url | text | public image link |
| category | text | Veg / Non-Veg / Drinks / Snacks |

## ⚙️ Supabase Setup (Quick)
1. Create project → Table Editor → new table `menu_items` with columns above.
2. Insert a few rows (use public image URLs or Supabase Storage public bucket).
3. If Row Level Security is ON add a SELECT policy (USING: `true`) for role `anon`.
4. Copy project URL & anon key into `lib/main.dart`.

## 🚀 Run Locally
```bash
flutter pub get
flutter run -d chrome   # or any connected device
```

## 🌐 Build for Web Deployment
```bash
flutter build web
```
Upload the contents of `build/web` to Netlify / Vercel / GitHub Pages.

## 🧩 Next Ideas (Not Implemented Yet)
* Persist favorites & theme (SharedPreferences)
* User auth (Supabase email / magic link)
* Better error/retry UI & loading skeletons
* Deploy CI workflow (GitHub Actions)

## 📄 License
Educational / personal use. Add an explicit LICENSE file before publishing widely.

---
Small, clear, and intentionally simple for portfolio learning.