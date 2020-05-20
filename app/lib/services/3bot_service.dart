import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:package_info/package_info.dart';
import 'package:threebotlogin/app_config.dart';
import 'package:threebotlogin/services/crypto_service.dart';
import 'package:threebotlogin/services/user_service.dart';

String threeBotApiUrl = AppConfig().threeBotApiUrl();
Map<String, String> requestHeaders = {'Content-type': 'application/json'};

Future<Response> sendData(
    String state, data, selectedImageId, String randomRoom, String appId) async {
  return http.post('$threeBotApiUrl/signedAttempt',
      body: json.encode({
        'signedAttempt': await signData(
            json.encode({
              'signedState': state,
              'data': data,
              'selectedImageId': selectedImageId,
              'doubleName': await getDoubleName(),
              'randomRoom': randomRoom,
              'appId': appId
            }),
            await getPrivateKey()),
        'doubleName': await getDoubleName()
      }),
      headers: requestHeaders);
}

Future<Response> sendPublicKey(Map<String, Object> data) async {
  String timestamp = new DateTime.now().millisecondsSinceEpoch.toString();
  String privatekey = await getPrivateKey();

  Map<String, String> headers = {
    "timestamp": timestamp,
    "intention": "post-savederivedpublickey"
  };
  String signedHeaders = await signData(jsonEncode(headers), privatekey);

  Map<String, String> loginRequestHeaders = {
    'Content-type': 'application/json',
    'Jimber-Authorization': signedHeaders
  };

  return http.post('$threeBotApiUrl/savederivedpublickey',
      body: json.encode(data), headers: loginRequestHeaders);
}

Future<bool> isAppUpToDate() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  int currentBuildNumber = int.parse(packageInfo.buildNumber);
  int minimumBuildNumber = 0;

  String jsonResponse = (await http
          .get('$threeBotApiUrl/minimumversion', headers: requestHeaders)
          .timeout(const Duration(seconds: 3)))
      .body;
  Map<String, dynamic> minimumVersion = json.decode(jsonResponse);

  if (Platform.isAndroid) {
    minimumBuildNumber = minimumVersion['android'];
  } else if (Platform.isIOS) {
    minimumBuildNumber = minimumVersion['ios'];
  }

  return currentBuildNumber >= minimumBuildNumber;
}

Future<Response> cancelLogin(doubleName) {
  return http.post('$threeBotApiUrl/users/$doubleName/cancel',
      body: null, headers: requestHeaders);
}

Future<Response> getUserInfo(doubleName) {
  return http.get('$threeBotApiUrl/users/$doubleName', headers: requestHeaders);
}

Future<Response> finishRegistration(
    String doubleName, String email, String sid, String publicKey) async {
  return http.post('$threeBotApiUrl/mobileregistration',
      body: json.encode({
        'doubleName': doubleName + '.3bot',
        'sid': sid,
        'email': email.toLowerCase().trim(),
        'public_key': publicKey,
      }),
      headers: requestHeaders);
}
