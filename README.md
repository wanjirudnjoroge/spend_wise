# SpendWise

A Flutter expense-management app for small teams: track expenses, set category
budgets, review and approve spending, and manage corporate cards.

## Features

- Sign in / sign up with secure token storage
- Dashboard with remaining budget, spend by category and recent expenses
- Expenses: add, filter by status, approve / reject, delete
- Budgets: set a monthly limit per category and track progress
- Cards: view corporate cards, usage and freeze / unfreeze

## Run it

```bash
flutter pub get
flutter run
```

The app starts in **demo mode** with built-in sample data, so no backend is
needed. Sign in with `demo@spendwise.app` / `password123`.

### Connecting a real backend

```bash
flutter run --dart-define=USE_MOCK_API=false \
            --dart-define=API_BASE_URL=https://your-api.example.com
```

Routes are defined in `lib/core/constants/app_constants.dart`. The app expects
JSON with snake_case fields; see `lib/model/` for the exact shapes.

## Project structure

```
lib/
  core/          config, constants, theme, errors, networking, shared widgets
  model/         data classes (User, Expense, Budget, CorporateCard, ...)
  services/      API classes (HTTP) and in-memory demo implementations
  repositories/  thin layer between services and view models
  view_model/    Riverpod state (ChangeNotifier-based)
  screens/       UI
```

## Test

```bash
flutter analyze
flutter test
```
