import 'dart:core';
import 'dart:math';

const chars = "abcdefghijklmnopqrstuvwxyz0123456789";

String randomString(int strlen) {
  Random rnd = new Random(new DateTime.now().millisecondsSinceEpoch);
  String result = "";

  for (int i = 0; i < strlen; i++) {
    result += chars[rnd.nextInt(chars.length)];
  }

  return result;
}

bool validateEmail(String value) {
  Pattern pattern = r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}';
  
  RegExp regex = new RegExp(pattern);
  if (!regex.hasMatch(value)) {
    return false;
  }
  return true;
}

bool validateSeedWords(String seed, String confirmationWords) {
  List<String> words = confirmationWords.split(" ");
  List<String> seedWords = seed.split(" ");

  // if lenght is not correct return already here
  if (words.length != 3) return false;

  for (final String word in words) {
    // check every word in list against the seed
    if (!seedWords.contains(word)) {
      return false;
    }
  }
  return true;
}

String validateDoubleName(String value) {
  Pattern pattern = r'^[a-zA-Z0-9]+$';
  RegExp regex = new RegExp(pattern);
  if (!regex.hasMatch(value)) {
    return 'Enter Valid Email';
  }
  return null;
}
