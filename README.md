# Trailing Stops

A Flutter web app for managing trailing stop orders on your Schwab brokerage account.

## Features

- View open positions with active trailing stop orders
- Displays current price, trail stop price, and locked-in profit per position
- Trail stop price is calculated from the highest price since order entry minus the trail gap
- Locked profit shown only when positive: `(highestHigh - trailGap - avgCost) × qty`
- Auto-refreshes positions every minute, price history every 10 minutes
- Falls back to demo data when the Schwab API is unavailable

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart SDK ^3.11.1)
- A [Schwab Developer](https://developer.schwab.com/) app with OAuth credentials

## Setup

1. Clone the repo and install dependencies:
   ```bash
   flutter pub get
   ```

2. Configure your Schwab OAuth credentials in `lib/services/auth_service.dart`.

3. Run in the browser:
   ```bash
   flutter run -d chrome
   ```

4. Or build for web:
   ```bash
   flutter build web
   ```

## Runtime Workflow

What the app does once it's open:

```
LOGIN
  └─► OAuth redirect to Schwab → token stored in AuthService

PORTFOLIO SCREEN
  ├─► every 60s:  GET /accounts?fields=positions
  │               GET /accounts/{hash}/orders     (active trailing stops)
  │               → recalculate trail stop price = highestHigh - trailGap
  │               → compute locked profit = (trail stop - avgCost) × qty
  │
  └─► every 10m:  GET /marketdata/v1/pricehistory  (per ticker)
                  → updates "highestHigh" used by the trail calculation

TRADE PAGE
  └─► POST /accounts/{hash}/orders                 (place trailing stop)
```

Both timers are managed in `lib/screens/portfolio_screen.dart`. The 60-second positions loop is the main UX feedback; the 10-minute price-history loop exists to keep API call volume under Schwab's quota while still catching the highs that drive the trail.

When any of those calls fail (network down, token expired, API outage), the screen falls back to **demo data** in `schwab_api_service.dart` so the UI doesn't appear broken during local dev.

## Build & Deploy Pipeline

The web build is hosted as a static site on **Cloudflare Workers** via [Wrangler](https://developers.cloudflare.com/workers/wrangler/) (`wrangler.jsonc`).

```
flutter build web         →  build/web/  (static bundle: index.html, main.dart.js, assets)
        │
        ▼
wrangler deploy           →  Cloudflare Workers serves build/web/ as static assets
                             (nodejs_compat flag enabled, observability on)
```

There's a `build.sh` for one-shot production builds and `run.bat` for opening a local dev session on Windows. OAuth tokens stay client-side; there's no server component beyond Cloudflare serving the static bundle, so deploys don't require any worker-side secrets.

## CI

`.github/workflows/ci.yml` runs on every push and PR:

1. **`flutter pub get`** — install dependencies
2. **`flutter analyze`** — static analysis using the rules in `analysis_options.yaml` (Flutter's recommended lints)
3. **`flutter test`** — runs widget/unit tests in `test/`
4. **`flutter build web`** — sanity-check that the production web bundle compiles

No deploy step in CI — `wrangler deploy` is run manually from `build.sh` so production pushes stay deliberate.

## Project Structure

```
lib/
  main.dart                  # App entry point
  navigation/
    main_navigation.dart     # Bottom nav shell
  screens/
    auth_gate.dart           # Checks auth state before routing
    login_screen.dart        # OAuth login flow
    portfolio_screen.dart    # Positions + trailing stops dashboard
    trade_page.dart          # Place / modify a trailing stop order
    placeholder_screen.dart  # Stub screens
  services/
    auth_service.dart        # OAuth token management
    schwab_api_service.dart  # Schwab REST API calls
```

## API Endpoints Used

| Endpoint | Purpose |
|---|---|
| `GET /accounts?fields=positions` | Fetch open positions |
| `GET /accounts/accountNumbers` | Resolve account hash |
| `GET /accounts/{hash}/orders` | Fetch active trailing stop orders |
| `POST /accounts/{hash}/orders` | Place a new trailing stop order |
| `GET /marketdata/v1/pricehistory` | Candle data for high-price tracking |

## License

MIT
