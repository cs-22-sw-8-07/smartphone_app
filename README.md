# smartphone_app

Flutter client project made by group cs-21-sw-7-08

## Getting Started

Google API keys has been GIT ignored from the project so they have to be added manually.

First a google-services files have to be added to both the Android and iOS projects: 

```
project
└───android
│   └───app   
│       │   google-services.json
└───ios
```

Afterwards a .env has to be added in the root of the project

```
project
└───.env
```

With the following values:

```
GOOGLE_API_KEY=API_KEY_FROM_GOOGLE_CLOUD_CONSOLE
```