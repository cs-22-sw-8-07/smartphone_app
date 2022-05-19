
import 'dart:io';

import 'package:flutter/material.dart';

class KeyHelper {

  static Key? get uniqueKey {
    if (Platform.environment.containsKey('FLUTTER_TEST')) return null;
    return UniqueKey();
  }

}