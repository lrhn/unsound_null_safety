// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart=2.7

import "package:test/test.dart";

import "src/null_safe.dart";

void main() {
  test("checkNotNullable", () {
    expect(check(1), 1);
    expect(() => check(null), throwsTypeError);
    expect(checkOptional(value: 1), 1);
    expect(() => checkOptional(value: null), throwsTypeError);
    expect(() => checkOptional(), throwsTypeError);
    expect(checkArgument(1), 1);
    expect(() => checkArgument(null), throwsTypeError);
    expect(checkIfNull(1), 1);
    expect(checkIfNull(null), 42);
    expect(checkArgumentIfNull(1), 1);
    expect(checkArgumentIfNull(null), 42);
    expect(castInt(1), 1);
    expect(() => castInt(null), throwsTypeError);
    expect(cast<int>(1), 1);
    expect(() => cast<int>(null), throwsTypeError);
  });
}

final throwsTypeError = throwsA(isA<TypeError>());
