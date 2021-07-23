import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:convert/convert.dart';

import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/services/3bot_service.dart';
import 'package:threebotlogin/services/crypto_service.dart';

Future<void> savePin(pin) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('pin');
  prefs.setString('pin', pin);
}

Future<String> getPin() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('pin');
}

Future<void> savePublicKey(key) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('publickey');
  prefs.setString('publickey', key);
}

Future<String> getPublicKey() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  if (!(await getIsPublicKeyFixed())) {
    var userInfoResponse = await getUserInfo(await getDoubleName());

    if (userInfoResponse.statusCode != 200) {
      throw new Exception('User not found');
    }

    var userInfo = json.decode(userInfoResponse.body);
    var done = await prefs.setString("publickey", userInfo['publicKey']);

    if (done && prefs.getString('publickey') == userInfo['publicKey']) {
      setPublicKeyFixed();
    }
  }

  return prefs.getString('publickey');
}

Future<Map<String, String>> getEdCurveKeys() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final String pkEd = prefs.getString('publickey');
  final String skEd = prefs.getString('privatekey');

  final String pkCurve = base64.encode(
      await Sodium.cryptoSignEd25519PkToCurve25519(base64.decode(pkEd)));
  final String skCurve = base64.encode(
      await Sodium.cryptoSignEd25519SkToCurve25519(base64.decode(skEd)));


  return {
    'signingPublicKey': hex.encode(base64.decode(pkEd)),
    'signingPrivateKey': hex.encode(base64.decode(skEd)),
    'encryptionPublicKey': hex.encode(base64.decode(pkCurve)),
    'encryptionPrivateKey': hex.encode(base64.decode(skCurve))
  };
}

Future<void> setPublicKeyFixed() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('ispublickeyfixed', true);
}

Future<bool> getIsPublicKeyFixed() async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getBool('ispublickeyfixed') == null) {
      return false;
    }

    return prefs.getBool('ispublickeyfixed');
  } catch (_) {
    return false;
  }
}

Future<void> savePrivateKey(key) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('privatekey');
  prefs.setString('privatekey', key);
}

Future<String> getPrivateKey() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('privatekey');
}

Future<void> savePhrase(phrase) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('phrase');
  prefs.setString('phrase', phrase);
}

Future<String> getPhrase() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('phrase');
}

Future<void> saveLocationId(String locationId) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  List<dynamic> locationIdList = await getLocationIdList();

  locationIdList.add(locationId);

  String locationIdListAsJson = jsonEncode(locationIdList);

  prefs.remove('locationIdList');
  prefs.setString('locationIdList', locationIdListAsJson);
}

Future<List<dynamic>> getLocationIdList() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  try {
    String locationIdListAsJson = prefs.getString('locationIdList');
    List<dynamic> locationIdList = jsonDecode(locationIdListAsJson);

    return locationIdList;
  } catch (_) {
    return new List<dynamic>();
  }
}

Future<void> saveDoubleName(doubleName) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('doubleName');
  prefs.setString('doubleName', doubleName);
}

Future<String> getDoubleName() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('doubleName');
}

Future<void> removeEmail() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  prefs.remove('email');
  prefs.remove('emailVerified');
}

Future<void> saveEmail(String email, String signedEmailIdentifier) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('email');
  prefs.setString('email', email);

  prefs.remove('emailVerified');
  prefs.setString('signedEmailIdentifier', signedEmailIdentifier);

  Globals().emailVerified.value = (signedEmailIdentifier != null);
}

Future<Map<String, Object>> getEmail() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return {
    'email': prefs.getString('email'),
    'sei': prefs.getString('signedEmailIdentifier')
  };
}

Future<void> removePhone() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  prefs.remove('phone');
  prefs.remove('phoneVerified');
}

Future<void> savePhone(String phone, String signedPhoneIdentifier) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('phone');
  prefs.setString('phone', phone);

  prefs.remove('phoneVerified');
  prefs.setString('signedPhoneIdentifier', signedPhoneIdentifier);

  Globals().phoneVerified.value = (signedPhoneIdentifier != null);
}

Future<Map<String, Object>> getPhone() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return {
    'phone': prefs.getString('phone'),
    'spi': prefs.getString('signedPhoneIdentifier')
  };
}

Future<Map<String, Object>> getKeys(String appId, String doubleName) async {
  return await generateDerivedKeypair(appId, doubleName);
}

Future<String> getDerivedSeed(String appId) async {
  return await generateDerivedSeed(appId);
}

Future<void> saveFingerprint(fingerprint) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('fingerprint');
  prefs.setBool('fingerprint', fingerprint);
}

Future<bool> getFingerprint() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool result = prefs.getBool('fingerprint');

  if (result == null) {
    await prefs.setBool('fingerprint', false);
    result = prefs.getBool('fingerprint');
  }

  return result;
}

Future<void> saveScopePermissions(scopePermissions) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('scopePermissions');
  prefs.setString('scopePermissions', scopePermissions);
}

Future<String> getScopePermissions() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('scopePermissions');
}

Future<void> savePreviousScopePermissions(
    String appId, String scopePermissions) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('$appId-scopePreviousPermissions');
  await prefs.setString('$appId-scopePreviousPermissions', scopePermissions);
}

Future<String> getPreviousScopePermissions(String appId) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('$appId-scopePreviousPermissions');
}

Future<bool> isTrustedDevice(String appId, String trustedDevice) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String trustedDeviceApp = prefs.getString('$appId-trusted');
  if (trustedDeviceApp == null) return false;

  return trustedDeviceApp == trustedDevice;
}

Future<void> saveTrustedDevice(String appId, String trustedDeviceId) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('$appId-trusted');
  prefs.setString('$appId-trusted', trustedDeviceId);
}

Future<void> saveInitDone() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('initDone', true);
}

Future<bool> getInitDone() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool initDone = prefs.getBool('initDone');
  if (initDone == null) {
    initDone = false;
  }
  return initDone;
}

Future<bool> savePreviousState(String state) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return await prefs.setString("previousState", state);
}

Future<String> getPreviousState() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString("previousState");
}

Future<bool> clearData() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool cleared = await prefs.clear();
  saveInitDone();
  return cleared;
}