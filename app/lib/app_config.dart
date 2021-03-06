import 'package:threebotlogin/app_config_local.dart';
import 'package:threebotlogin/helpers/env_config.dart';
import 'package:threebotlogin/helpers/environment.dart';

class AppConfig extends EnvConfig {
  AppConfigImpl appConfig;

  AppConfig() {
    if (environment == Environment.Staging) {
      appConfig = AppConfigStaging();
    } else if (environment == Environment.Production) {
      appConfig = AppConfigProduction();
    } else if (environment == Environment.Testing) {
      appConfig = AppConfigTesting();
    } else if (environment == Environment.Local) {
      appConfig = AppConfigLocal();
    }
  }

  String baseUrl() {
    return appConfig.baseUrl();
  }

  String openKycApiUrl() {
    return appConfig.openKycApiUrl();
  }

  String threeBotApiUrl() {
    return appConfig.threeBotApiUrl();
  }

  String threeBotFrontEndUrl() {
    return appConfig.threeBotFrontEndUrl();
  }

  String threeBotSocketUrl() {
    return appConfig.threeBotSocketUrl();
  }

  String wizardUrl() {
    return appConfig.wizardUrl();
  }
}

abstract class AppConfigImpl {
  String baseUrl();

  String openKycApiUrl();

  String threeBotApiUrl();

  String threeBotFrontEndUrl();

  String threeBotSocketUrl();

  String wizardUrl();
}

class AppConfigProduction extends AppConfigImpl {
  String baseUrl() {
    return "login.threefold.me";
  }

  String openKycApiUrl() {
    return "https://openkyc.live";
  }

  String threeBotApiUrl() {
    return "https://login.threefold.me/api";
  }

  String threeBotFrontEndUrl() {
    return "https://login.threefold.me/";
  }

  String threeBotSocketUrl() {
    return "wss://login.threefold.me";
  }

  String wizardUrl() {
    return 'https://wizard.jimber.org/';
  }
}

class AppConfigStaging extends AppConfigImpl {
  String baseUrl() {
    return "login.staging.jimber.org";
  }

  String openKycApiUrl() {
    return "https://openkyc.staging.jimber.org";
  }

  String threeBotApiUrl() {
    return "https://login.staging.jimber.org/api";
  }

  String threeBotFrontEndUrl() {
    return "https://login.staging.jimber.org/";
  }

  String threeBotSocketUrl() {
    return "wss://login.staging.jimber.org";
  }

  String wizardUrl() {
    return 'https://wizard.staging.jimber.org/';
  }
}

class AppConfigTesting extends AppConfigImpl {
  String baseUrl() {
    return "login.testing.jimber.org";
  }

  String openKycApiUrl() {
    return "https://openkyc.testing.jimber.org";
  }

  String threeBotApiUrl() {
    return "https://login.testing.jimber.org/api";
  }

  String threeBotFrontEndUrl() {
    return "https://login.testing.jimber.org/";
  }

  String threeBotSocketUrl() {
    return "wss://login.testing.jimber.org";
  }

  String wizardUrl() {
    return 'https://wizard.staging.jimber.org/';
  }
}
