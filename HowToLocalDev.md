# HowToLocalDev

---

### example configuration 'example/public/config.js' (Change IP to yours where it is required.)

---

```javascript
export default {
  botFrontEnd: "http://192.168.1.2:8080",
  botBackend: "http://192.168.1.2:5000",
  kycBackend: "https://openkyc.staging.jimber.org",
  redirect_url: `/callback`,
  appId: window.location.host,
  seedPhrase:
    "weather smooth little world side palace green armor busy view solution escape",
};
```

### example

---

- cd example/
- yarn && yarn run serve

### frontend configuration 'frontend/public/config.js' (Change IP to yours where it is required.)

---

```javascript
export default {
  apiurl: "http://192.168.1.2:5000/",
  openkycurl: "https://openkyc.staging.jimber.org/",
};
```

### frontend

---

- cd frontend/
- yarn && yarn run serve

### uwsgi

---

- sudo apt update && sudo apt install -y python3 python3-pip gcc libssl-dev python-gevent # Use brew on macOS.
- pip3 uninstall uwsgi
- CFLAGS="-I/usr/local/opt/openssl/include" LDFLAGS="-L/usr/local/opt/openssl/lib" UWSGI_PROFILE_OVERRIDE=ssl=true pip3 install uwsgi==2.0.19.1 -I --no-cache-dir

### backend

---

- cd backend/
- uwsgi --http :5000 --gevent 1000 --http-websockets --master --wsgi-file **main**.py --callable app -s 0.0.0.0:3030

### flutter

---

- Use flutter channel stable.

### app configuration 'app/lib/app_config_local.dart' (Change IP to yours where it is required.)

---

- cd app/
- ./build.sh --init
- ./build.sh --switch --local

```dart
import 'package:threebotlogin/app_config.dart';

class AppConfigLocal extends AppConfigImpl {
    String baseUrl() {
        return "192.168.1.2:5000";
    }

    String openKycApiUrl() {
        return "https://openkyc.staging.jimber.org";
    }

    String threeBotApiUrl() {
        return "http://192.168.1.2:5000/api";
    }

    String threeBotFrontEndUrl() {
        return "http://192.168.1.2:8080/";
    }

    String threeBotSocketUrl() {
        return "http://192.168.1.2:5000";
    }

    String wizardUrl() {
        return 'https://wizard.staging.jimber.org/';
    }
}
```

### app

---

- cd app/
- flutter clean && flutter pub get
- cd ios/ && pod install # ONLY FOR macOS
- flutter run # in the app folder.
