# RevisionOS

> Premium spaced repetition & revision planning system for serious students.

Built with React, Vite, Supabase, and Framer Motion. Designed like a Xiaomi × Linear × Vercel product.

---

## 🚀 Quick Start

### 1. Clone & Install

```bash
git clone https://github.com/yourusername/revisionos.git
cd revisionos
npm install
```

### 2. Set Up Supabase

1. Go to [supabase.com](https://supabase.com) → New Project
2. Copy your **Project URL** and **anon public key**
3. Go to **SQL Editor** → paste and run the full contents of `supabase/schema.sql`
4. Go to **Storage** → create a bucket called `avatars` (set to public)

### 3. Configure Environment

```bash
cp .env.example .env
```

Edit `.env`:
```
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key-here
```

### 4. Run Locally

```bash
npm run dev
```

Open [http://localhost:5173](http://localhost:5173)

---

## 📦 Production Build

```bash
npm run build
npm run preview
```

---

## 🌐 Deploy to Vercel

### Option A — Vercel CLI

```bash
npm i -g vercel
vercel
```

When prompted, add environment variables:
- `VITE_SUPABASE_URL`
- `VITE_SUPABASE_ANON_KEY`

### Option B — Vercel Dashboard

1. Push to GitHub
2. Import project at [vercel.com/new](https://vercel.com/new)
3. Framework: **Vite**
4. Add environment variables in Settings → Environment Variables
5. Deploy

---

## 🗄️ Database Schema

Tables:
| Table | Purpose |
|---|---|
| `profiles` | User profiles, streak, theme settings |
| `subjects` | Top-level subject groupings |
| `chapters` | Individual chapters with priority/difficulty |
| `topics` | Sub-topics within chapters |
| `study_logs` | Manual study/revision logs |
| `revisions` | Spaced repetition revision schedule |
| `goals` | Daily/weekly/monthly goals |
| `achievements` | Unlocked achievements |
| `notifications` | In-app notification inbox |
| `focus_sessions` | Focus mode timer sessions |
| `daily_stats` | Aggregated daily activity |

---

## 🎨 Design System

| Token | Value |
|---|---|
| Font | DM Sans + DM Mono |
| Radius Scale | 4px → 32px |
| Themes | Dark, Light, AMOLED |
| Accent Colors | 8 presets + custom |
| Motion | Spring + ease curves |

---

## 📱 PWA

- Installable on desktop & mobile
- Offline support via Service Worker
- App shortcuts (Today's Revisions, Add Chapter)
- Background sync

### Generate App Icons

```bash
npm install canvas
node scripts/generate-icons.js
```

Or use [realfavicongenerator.net](https://realfavicongenerator.net) to create icons and place them in `public/icons/`.

---

## 🔐 Security

- Supabase RLS on all tables
- Protected routes via React Router
- PKCE auth flow
- Input sanitization
- Security headers via `vercel.json`

---

## 📂 Project Structure

```
revisionos/
├── public/
│   ├── icons/          # PWA app icons
│   └── favicon.svg
├── src/
│   ├── components/
│   │   ├── common/     # AppShell, Loading, Toast
│   │   └── search/     # CommandPalette
│   ├── contexts/       # Auth, App, Data contexts
│   ├── hooks/          # Custom React hooks
│   ├── pages/          # Route pages
│   ├── services/       # Supabase client, DB service, notifications
│   ├── styles/         # globals.css + components.css
│   └── utils/          # Helpers, constants
├── supabase/
│   └── schema.sql      # Full DB schema + RLS
├── scripts/
│   └── generate-icons.js
├── vite.config.js
├── vercel.json
└── .env.example
```

---

## 🧠 Spaced Repetition

RevisionOS uses the **Ebbinghaus Forgetting Curve** intervals:

| Revision # | Days After Study |
|---|---|
| 1 | +1 day |
| 2 | +3 days |
| 3 | +7 days |
| 4 | +14 days |
| 5 | +30 days |
| 6 | +60 days |
| 7 | +90 days |

Ratings (1–5) affect the next interval scheduling. Rating ≥ 4 confirms retention.

---

## 🏆 Features

- ✅ Dashboard with heatmap, streak, today's revisions
- ✅ Chapter & subject management
- ✅ Spaced repetition engine (auto-generated schedules)
- ✅ Focus Mode with countdown timer
- ✅ Analytics with charts (bar, area, radar, pie)
- ✅ Calendar (month / week / agenda)
- ✅ Goals (daily, weekly, monthly)
- ✅ Achievement system
- ✅ Notification center
- ✅ Command palette (⌘K)
- ✅ Theme system (dark / light / AMOLED)
- ✅ Dynamic accent colors
- ✅ PWA (installable, offline)
- ✅ Realtime sync via Supabase
- ✅ Profile with avatar upload

---

## 📄 License

MIT
