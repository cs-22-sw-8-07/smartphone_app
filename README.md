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
CLIENT_ID=<SPOTIFY_CLIENT_ID>
FOURSQUARE_API_KEY=<API_KEY_FROM_FOURSQUARE>
REDIRECT_URL=myappdemo://callback
MOCK_POSITION_SERVER_IP=192.168.0.255
QUACK_API_URL=https://192.168.0.108:5001
WHICH_POSITION_HELPER=<mock|udp|device>
WHICH_QUACK_API=<mock|prod>
```

The value __CLIENT_ID__ is Spotify Client ID and it is pinned in #smartphone-app.  
The value __API_KEY_FROM_FOURSQUARE__ is pinned in #location-based-system.  
The value __WHICH_POSITION_HELPER__ should be 'mock', 'udp', or 'device'.

-   'mock' has no position helper.
    this is the easy and fast choice.
-   'udp' uses the location from repository 'gps_mock_data'.
    this is windows only.
    this may or may not work on an emulator.
    this is the default setting fot the sake of development.
-   'device' uses the sensors from the phone.
    this is the release setting.
    requires that the phone physically moves to change the position.
    
The value __WHICH_QUACK_API__ should be 'mock' or 'prod'

-   'mock' means that local data will be utilized.
-   'prod' means that the smartphone app connects to the Quack API.
    
### Setup

- The e-mail used for sign-up for the spotify account must be whitelisted by Jakob
- The SHA1 must be added to the developer dashboard by Jakob

Execute android/Tasks/android/signingReport gradle thingie (not a traditional file) to get the SHA1

## Demo

[![See the demonstration](https://i.ytimg.com/vi/GqphjZ-0HqE/maxresdefault.jpg)](https://youtu.be/GqphjZ-0HqE)
