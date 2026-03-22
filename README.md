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
