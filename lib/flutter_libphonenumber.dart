import 'dart:async';

import 'package:flutter/services.dart';

class PhoneNumber {
  final int countryCode;
  final int nationalNumber;
  final String numberExtension;
  final String formated;
  final String aytf;

  PhoneNumber.fromMap(map)
    : this.countryCode = map['countryCode'],
      this.nationalNumber = map['nationalNumber'],
      this.numberExtension = map['numberExtension'],
      this.formated = map['formated'],
      this.aytf = map['aytf'];
}

class FlutterLibPhoneNumber { 
  static const MethodChannel _channel =
      const MethodChannel('com.vizmo.flutterlibphonenumber');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<PhoneNumber> parse(String phoneNumber, {String defaultRegion = 'US'}) async {
    final args = {
      'phoneNumber': phoneNumber,
      'defaultRegion': 'AR',
      'ignoreType': true
    };
    final phoneMap = await _channel.invokeMethod('parse', args);
    print(phoneMap);
    return PhoneNumber.fromMap(phoneMap);
  }
}
