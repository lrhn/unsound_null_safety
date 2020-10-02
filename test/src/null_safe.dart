// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Null safe code.

import 'package:unsound_null_safey/unsound_null_safety.dart';

int check(int value) {
  return checkNotNullable(value);
}

int checkIfNull(int value) {
  return checkNotNullable(value, ifNull: 42);
}

int checkArgument(int value) {
  return checkArgumentNotNullable(value, "value");
}

int checkArgumentIfNull(int value) {
  return checkArgumentNotNullable(value, "value", ifNull: 42);
}

int castInt(Object? value) {
  return value.as<int>();
}

T cast<T>(Object? value) {
  return value.as<T>();
}

int checkOptional({required int value}) {
  return checkNotNullable(value);
}
