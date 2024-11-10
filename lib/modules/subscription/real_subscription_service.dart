// modules/subscription/real_subscription_service.dart

import 'subscription_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';
import 'package:pointycastle/export.dart';
import 'package:basic_utils/basic_utils.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
import 'package:device_info_plus/device_info_plus.dart';

class RealSubscriptionService implements SubscriptionService {
  final _storage = FlutterSecureStorage();

  // Constants for subscription limits
  final int maxDailyAttempts = 5;
  final int maxSubscriptionCount = 50;
  final String _subscriptionAttemptsKey = 'subscription_attempts';
  final String _subscriptionCountKey = 'subscription_count';
  final String _usedKeysStorageKey = 'used_subscription_keys';

  // Load public key
  RSAPublicKey _loadPublicKey() {
    final publicPem = '''-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvt8LTn/qbq0gJhCQagBK
LBfTKDYQhdGLrrAyPBZUjXsmEKK/VVGF8BMDrNIyKnuKdJ02mjXlSQ96kJHOznl5
7OPZdfU8V/TCjuyJI8bBAWMM+cfxRAO3NajTSPzJbgU7XfDWq5UbPwADgUgVU8+F
64sbcTPQgGnTXH2VZzdkw/nQ/ZryQ//BvAhAgewGK0mfMZjT0mGado/X4eQjI356
+gz0GyQIWCLou2Q984TVHTGUHp9uUoi6hdjqxqgN3ssg9ScB5jRte7ybu9mG0yFE
iEVzzSFnbUYjSJjftMAx8bwuAdnEehbw+0AYvbbi60y2UmHaJ0e2DPqUzDVzxSWD
hwIDAQAB
-----END PUBLIC KEY-----''';
    return CryptoUtils.rsaPublicKeyFromPem(publicPem);
  }

  // Fetch current subscription count
  Future<int> _getSubscriptionCount() async {
    String? countStr = await _storage.read(key: _subscriptionCountKey);
    return int.tryParse(countStr ?? '0') ?? 0;
  }

  // Save updated subscription count
  Future<void> _saveSubscriptionCount(int count) async {
    await _storage.write(key: _subscriptionCountKey, value: count.toString());
  }

  // Get today's attempt count
  Future<int> _getTodayAttempts() async {
    String? attemptsData = await _storage.read(key: _subscriptionAttemptsKey);
    if (attemptsData != null) {
      Map<String, dynamic> attempts = json.decode(attemptsData);
      String today = DateTime.now().toIso8601String().split('T')[0];
      if (attempts.containsKey(today)) return attempts[today];
    }
    return 0;
  }

  // Save today's attempt count
  Future<void> _saveTodayAttemptCount(int count) async {
    String today = DateTime.now().toIso8601String().split('T')[0];
    Map<String, dynamic> attempts = {today: count};
    await _storage.write(key: _subscriptionAttemptsKey, value: json.encode(attempts));
  }

  // Fetch list of used key hashes
  Future<Set<String>> _getUsedKeyHashes() async {
    String? jsonString = await _storage.read(key: _usedKeysStorageKey);
    if (jsonString == null || jsonString.isEmpty) return {};
    List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((e) => e.toString()).toSet();
  }

  // Save updated list of used key hashes
  Future<void> _saveUsedKeyHashes(Set<String> hashes) async {
    String jsonString = json.encode(hashes.toList());
    await _storage.write(key: _usedKeysStorageKey, value: jsonString);
  }

  // Get the overall expiry date
  @override
  Future<DateTime?> getOverallExpiryDate() async {
    String? expiryDateString = await _storage.read(key: 'subscription_expiry_date');
    if (expiryDateString == null) return null;
    return DateTime.parse(expiryDateString);
  }

  @override
  Future<String?> getExpiryDate() async {
    DateTime? expiryDate = await getOverallExpiryDate();
    return expiryDate?.toIso8601String();
  }

  @override
  Future<void> updateExpiryDate(int additionalMonths) async {
    DateTime now = DateTime.now();
    DateTime expiryDate = await getOverallExpiryDate() ?? now;

    // Process each month's increment individually to ensure correct date
    for (int i = 0; i < additionalMonths; i++) {
      expiryDate = DateTime(
        expiryDate.year,
        expiryDate.month + 1,
        expiryDate.day,
      );
    }

    await _storage.write(
        key: 'subscription_expiry_date',
        value: expiryDate.toIso8601String());
  }

  @override
  Future<void> validateSubscriptionKeys(List<String> subscriptionKeys) async {
    int todayAttempts = await _getTodayAttempts();
    int currentCount = await _getSubscriptionCount();

    // Check daily limit and permanent lock condition
    if (todayAttempts >= maxDailyAttempts) {
      print('Daily limit of subscription key attempts reached. Try again tomorrow.');
      return;
    }
    if (currentCount >= maxSubscriptionCount) {
      print('Subscription limit reached. No more keys can be applied.');
      return;
    }

    bool anyValid = false;
    Set<String> usedKeyHashes = await _getUsedKeyHashes();

    for (String key in subscriptionKeys) {
      if (key.trim().isEmpty) continue;
      String keyHash = sha256.convert(utf8.encode(key)).toString();

      if (usedKeyHashes.contains(keyHash)) {
        print('Subscription key already used: $key');
        continue;
      }

      bool isValid = await _validateSubscriptionKey(key);
      if (isValid) {
        int subscriptionCount = await _extractSubscriptionCount(key);
        if (subscriptionCount <= 0) {
          print('Invalid subscription count in key: $key');
          continue;
        }

        // Increment counts and update expiry date
        currentCount += 1;
        todayAttempts += 1;
        await _saveSubscriptionCount(currentCount);
        await _saveTodayAttemptCount(todayAttempts);
        await updateExpiryDate(subscriptionCount);
        usedKeyHashes.add(keyHash);
        anyValid = true;

        print('Subscription key activated: $key for $subscriptionCount months');

        // Check if permanent lock is reached
        if (currentCount >= maxSubscriptionCount) {
          print('Maximum subscription limit reached. Permanently locked.');
          return;
        }
      } else {
        print('Invalid subscription key: $key');
      }
    }

    if (anyValid) {
      await _saveUsedKeyHashes(usedKeyHashes);
      // Log the activity if needed
      return;
    }
  }

  Future<int> _extractSubscriptionCount(String subscriptionKey) async {
    try {
      String decodedKey = utf8.decode(base64.decode(subscriptionKey));
      Map<String, dynamic> subscriptionPackage = json.decode(decodedKey);
      String message = subscriptionPackage['message'];
      List<String> parts = message.split('|');
      if (parts.length != 3) return 0;
      String subscriptionCountStr = parts[2];
      return int.tryParse(subscriptionCountStr) ?? 0;
    } catch (e) {
      print('Error extracting subscription count: $e');
      return 0;
    }
  }

  Future<bool> _validateSubscriptionKey(String subscriptionKey) async {
    try {
      String decodedKey = utf8.decode(base64.decode(subscriptionKey));
      Map<String, dynamic> subscriptionPackage = json.decode(decodedKey);
      String message = subscriptionPackage['message'];
      String signatureBase64 = subscriptionPackage['signature'];
      Uint8List signatureBytes = base64.decode(signatureBase64);
      RSAPublicKey publicKey = _loadPublicKey();
      final signer = RSASigner(SHA256Digest(), '0609608648016503040201');
      signer.init(false, PublicKeyParameter<RSAPublicKey>(publicKey));
      bool isValid = signer.verifySignature(Uint8List.fromList(utf8.encode(message)), RSASignature(signatureBytes));

      if (!isValid) return false;

      List<String> parts = message.split('|');
      if (parts.length != 3) return false;

      String dateStr = parts[0];
      String nonce = parts[1];
      String subscriptionCountStr = parts[2];
      String expectedNonce = _generateNonce(dateStr);
      if (nonce != expectedNonce) return false;

      int subscriptionCount = int.tryParse(subscriptionCountStr) ?? 0;
      if (subscriptionCount <= 0) return false;

      final currentDeviceFingerprint = await _getDeviceFingerprint();
      String? storedFingerprint = await _storage.read(key: 'device_fingerprint');
      if (storedFingerprint == null) {
        await _storage.write(key: 'device_fingerprint', value: currentDeviceFingerprint);
      } else if (storedFingerprint != currentDeviceFingerprint) {
        return false;
      }

      return true;
    } catch (e, stacktrace) {
      print('Error validating subscription key: $e\n$stacktrace');
      return false;
    }
  }

  String _generateNonce(String dateStr) {
    return dateStr.split('').reversed.join('');
  }

  Future<String> _getDeviceFingerprint() async {
    if (kIsWeb) {
      return await _getWebDeviceFingerprint();
    } else {
      return await _getMobileDeviceFingerprint();
    }
  }

  Future<String> _getWebDeviceFingerprint() async {
  //  return await _getMobileDeviceFingerprint();
    try {
      String userAgent = html.window.navigator.userAgent ?? 'unknown_user_agent';
      String platform = html.window.navigator.platform ?? 'unknown_platform';
      String language = html.window.navigator.language ?? 'unknown_language';
      String fingerprintSource = '$userAgent|$platform|$language|${html.window.screen?.width}x${html.window.screen?.height}';
      var bytes = utf8.encode(fingerprintSource);
      var digest = sha256.convert(bytes);
      return base64.encode(digest.bytes);
    } catch (e) {
      print('Error generating device fingerprint for web: $e');
      return 'web_error_fingerprint';
    }
  }

  Future<String> _getMobileDeviceFingerprint() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return androidInfo.id ?? 'unknown_mobile_fingerprint';
  }

  @override
  Future<bool> isSubscriptionActive() async {
    DateTime? expiryDate = await getOverallExpiryDate();
    if (expiryDate == null) return false;
    return expiryDate.isAfter(DateTime.now());
  }
}
