# restaurant-invenapp-main

## Firebase config (do not commit keys)

This repo intentionally does **not** include `GoogleService-Info.plist` (it previously contained a real API key).

The Xcode project now generates the Firebase plist **at build time** into the app bundle.

### Option A (recommended for CI): base64 env var

- Set `GOOGLESERVICE_INFO_PLIST_BASE64` to the base64-encoded contents of your real `GoogleService-Info.plist`.

Example (macOS):

```bash
export GOOGLESERVICE_INFO_PLIST_BASE64="$(base64 < GoogleService-Info.plist | tr -d '\n')"
```

### Option B (recommended for local dev): file path env var

- Set `GOOGLESERVICE_INFO_PLIST_PATH` to the absolute path of your real `GoogleService-Info.plist`.

Example:

```bash
export GOOGLESERVICE_INFO_PLIST_PATH="$HOME/secrets/GoogleService-Info.plist"
```

### Template

Use `GoogleService-Info.plist.example` as a placeholder/template (it contains **no real keys**).

