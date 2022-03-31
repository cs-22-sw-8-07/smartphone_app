# smartphone_app

Flutter client project made by group cs-22-sw-8-07

## Getting Started

### Requirements

- Flutter SDK installed on computer
- Working Android phone or emulator with Spotify app installed
- Spotify (premium?) account

### Env file

A .env has to be added in the root of the project

```
project
└───.env
```

With the following values:

```
GOOGLE_API_KEY=<API_KEY_FROM_GOOGLE_CLOUD_CONSOLE>
CLIENT_ID=<SPOTIFY_CLIENT_ID>
FOURSQUARE_API=<API_KEY_FROM_FOURSQUARE>
REDIRECT_URL=myappdemo://callback
MOCK_POSITION_SERVER_IP=192.168.0.255
QUACK_API_URL=https://192.168.0.108:5001
```

The value API_KEY_FROM_GOOGLE_CLOUD_CONSOLE is no longer needed
The value SPOTIFY_CLIENT_ID is pinned in #smartphone-app
The value API_KEY_FROM_FOURSQUARE is pinned in #location-based-system

### Setup

- The e-mail used for sign-up for the spotify account must be whitelisted by Jakob
- The SHA1 must be added to something by Jakob

Execute android/Tasks/android/signingReport gradle thingie (not a traditional file) to get the SHA1