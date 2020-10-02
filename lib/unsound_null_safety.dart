// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Utility functions for dealing with unsound null-safety.
///
/// The "null safety" feature protects programs
/// against accidental `null` errors,
/// but it is only guranteed to be sound
/// when all libraries in the program have been migrated
/// or rewritten for null safety.
/// Until then, in a "mixed mode" program,
/// non-nullable variables might still end up containing `null`.
/// Also, the `as` cast operator accepts `null` in unsound mode,
/// even in null safe libraries.
///
/// For situations where it's important to guard against
/// such `null` values, this library provides functions which
/// check whether a non-nullable variable is actually `null`,
/// and a cast operation which does not accept `null` for
/// non-nullable types.
///
/// Using these functions will make it easy to *remove* them again
/// when the entire program has been made null safe.
/// This is better than using [ArgumentError.checkNotNull]
/// because that function might used in some places even after
/// null safet.
/// The typing of the checks also ensure that they are only used
/// on values that are actually non-nullable, so that removing
/// the checks later won't change the behavior of a
/// sound null safe program.
library unsound_null_safety;

/// Checks whether a non-nullable expression evaluates to `null`.
///
/// This can only happen in *unsound* null safety mode.
///
/// Returns [value] if it is not `null`.
/// If the [value] is `null`, then returns the [ifNull] value
/// if *that* is non-`null`. Otherwise throws an [UnsoundError].
///
/// Use this check rather than [ArgumentError.checkNotNull],
/// so that it is easy to find and remove the unnecessary check
/// again when your program becomes fully and soundly null-safe.
///
/// Use this check with an [ifNull] value if you change a parameter
/// to from optional in non-null safe code to required in null safe
/// code. This can be a reasonable migration strategy for APIs
/// where the nullability of a parameter was not a deliberate
/// design choice, but more something added on because
/// there was no way to disallow `null`s.
///
/// Example use:
/// ```dart
/// int sliceFirst(List<String> elements, int min, int max) {
///   var first = checkNotNullable(elements.first);
///   return first.substring(checkArgumentNotNullable(start),
///       checkArgumentNotNullable(end, ifNull: first.length));
/// }
/// ```
///
/// Don't use this function on every possible expression which
/// might be `null`. If your pre-null safety code didn't guard
/// against `null` values, then there is no reason to start now.
/// It's fine to just let things fail with an invocation on `null`,
/// so only check eagerly when failing early is an advantage,
/// for example to avoid a large computation which won't be used,
/// or to avoid failing in the middle of updating some object's
/// state.
T checkNotNullable<T extends Object>(T value, {T? ifNull}) {
  if (value as dynamic == null) {
    if (ifNull == null) throw UnsoundError<T>.nullCheck();
    return ifNull;
  }
  return value;
}

/// Checks whether a non-nullable parameter is `null`.
///
/// This can only happen in *unsound* null safety mode.
///
/// The [name] is the name of the parameter,
/// and is used in the error message.
/// If there is no relevant name, use [checkNotNullable] instead.
///
/// Returns [value] if the value is not `null`.
/// If the [value] is `null`, then returns the [ifNull] value
/// if *that* is non-`null`. Otherwise throws an [UnsoundError].
///
/// Use this check rather than [ArgumentError.checkNotNull],
/// so that it is easy to find and remove the unnecessary check
/// again when your program becomes fully and soundly null-safe.
///
/// Use this check with an [ifNull] value if you change a parameter
/// to from optional in non-null safe code to required in null safe
/// code. This can be a reasonable migration strategy for APIs
/// where the nullability of a parameter was not a deliberate
/// design choice, but more something added on because
/// there was no way to disallow `null`s.
///
/// Example use:
/// ```dart
/// int sliceFirst(List<String> elements, int min, int max) {
///   var first = checkNotNullable(elements.first);
///   return first.substring(checkArgumentNotNullable(start),
///       checkArgumentNotNullable(end, ifNull: first.length));
/// }
/// ```
///
/// Don't use this function on every possible argument which
/// might be `null`. If your pre-null safety code didn't guard
/// against `null` values, then there is no reason to start now.
/// It's fine to just let things fail with an invocation on `null`,
/// so only check eagerly when failing early is an advantage,
/// for example to avoid a large computation which won't be used,
/// or to avoid failing in the middle of updating some object's
/// state.
T checkArgumentNotNullable<T extends Object>(T value, String name,
    {T? ifNull}) {
  if (value as dynamic == null) {
    if (ifNull == null) throw UnsoundError<T>.nullArgumentCheck(name);
    return ifNull;
  }
  return value;
}

/// Sound cast extension for unsound null-safe mode.
extension UnsoundCast on Object? {
  /// Cast the expression to [T].
  ///
  /// Works like `as T` except that it does not accept `null`
  /// unless `null is T` is `true`, even in unsound null-safe mode.
  /// Throws an [UnsoundError].
  ///
  /// Use this in a situation where it's *important* to not recognize
  /// `null`, which is mainly for checking values managed inside
  /// a single library.
  ///
  /// If the type in question is a type parameter,
  /// it's better to use an `as` cast,
  /// because callers from non-null safe code
  /// might intend the type to include `null` values.
  ///
  /// Example:
  /// ```dart
  /// class FlooIterator implements Iterator<Floo> {
  ///   Floos _floos;
  ///   Floo? _current;
  ///   bool moveNext() {
  ///     if (_floos.hasMore()) {
  ///       _current = _floos.next();
  ///       return true;
  ///     }
  ///     _current = null;
  ///     return false;
  ///   }
  ///   Floo get current => _current.as<Floo>(); // Not `_current as Floo`.
  /// }
  /// ```
  /// Here the nullability of the `_current` variable is
  /// used internally in the iterator implementation.
  ///
  /// Don't use this method instead of `as` unless not accepting `null`
  /// is essential, and even then, it's usually better to throw a
  /// more precise error instead of a `TypeError`.
  T as<T>() {
    var result = this as T;
    if (result != null || null is T) return result;
    throw UnsoundError<T>.cast();
  }
}

/// Error thrown when a check fails due to unsound null-safety.
class UnsoundError<T> extends TypeError {
  final String _message;

  /// Error thrown by [checkNotNullable] when a value is unsoundly `null`.
  UnsoundError.nullCheck()
      : _message =
            "A non-nullable expression of type $T was null due to unsoundness";

  UnsoundError.nullArgumentCheck(String name)
      : _message =
            "The '$name parameter of type $T  was null due to unsoundness";

  /// Error thrown by [UnsoundCast.as] when the value is unsoundly `null`.
  UnsoundError.cast() : _message = "A null value was cast to $T";

  @override
  String toString() => "UnsoundError: $_message";
}
