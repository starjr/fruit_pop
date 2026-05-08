# Fruit Pop

A pastel-themed fruit-merging puzzle game built with Flutter. Drop fruits, merge identical ones, and chain combos all the way to a watermelon. Two watermelons merging — or any fruit crossing the LIMIT line — ends the game.

> **Bundle ID**: `io.starjr.fruitpop`
> **Platform**: Android (Google Play) — iOS/Web/Desktop ready by default Flutter scaffolding.

## Features

- **Custom 2D physics engine** — gravity, collision resolution, restitution, friction, resting state, tipping. No external physics library; tuned in-house for fast, jitter-free merges.
- **11 fruit tiers** — 체리 → 딸기 → 포도 → 한라봉 → 감 → 사과 → 배 → 복숭아 → 파인애플 → 멜론 → 수박.
- **Game over rules**
  - Any fruit resting above the LIMIT line for ~90 frames.
  - Two watermelons merging (counts as a victory pop with bonus points).
- **Local persistence** with `shared_preferences`
  - Best score, recent games, coins, owned/equipped skins, daily challenges, settings (BGM/SFX/haptic/push), nickname.
- **Daily challenges** with rotating goals and coin rewards.
- **Skin shop** with previewable, purchasable fruit styles.
- **In-app privacy policy** viewer (settings → 이용약관).
- **Korean localization** (UI text in Korean).
- **Polished UI** — fully painted fruits via `CustomPainter`, `RepaintBoundary` isolation, `Ticker`-driven game loop.

## Project layout

```
lib/
├── main.dart                       # entry + LocalStore.init()
├── data/
│   ├── fruit_data.dart             # 11 fruit metadata
│   └── legal_text.dart             # in-app privacy policy text
├── services/
│   └── local_store.dart            # shared_preferences wrapper (scores/coins/skins/challenges/settings)
├── theme/
│   └── app_colors.dart             # candy color tokens
├── widgets/
│   ├── pop_button.dart             # toy-style buttons + cards
│   ├── icons.dart                  # custom SVG-style icons
│   ├── mascot.dart                 # watermelon mascot painter
│   └── fruits/fruit_painters.dart  # 11 fruit CustomPainters
└── screens/
    ├── home_screen.dart
    ├── game_screen.dart            # custom physics + game loop
    ├── result_screen.dart
    ├── leaderboard_screen.dart     # "내 기록" — best & recent
    ├── settings_screen.dart
    ├── shop_screen.dart
    └── legal_screen.dart
store/
├── privacy_policy.md               # public-facing privacy policy (host on GitHub Pages)
└── RELEASE_CHECKLIST.md            # Play Store submission checklist
```

## Getting started

Requires Flutter SDK (3.x). Then:

```bash
flutter pub get
flutter run
```

To run tests:

```bash
flutter test
flutter analyze
```

## Building for release (Android)

Signing config lives in `android/key.properties` and `android/fruitpop-release.jks` — both are git-ignored. To produce an AAB:

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`.

See [`store/RELEASE_CHECKLIST.md`](store/RELEASE_CHECKLIST.md) for the full Play Store submission flow.

## Privacy

The app stores all user data locally on device (`shared_preferences`) — no server, no analytics SDK, no third-party data sharing.

Public privacy policy: [`store/privacy_policy.md`](store/privacy_policy.md).

## License

All rights reserved.
