Utility functions for dealing with unsound null safety.

The Dart null safety language feature comes in two flavors.
Until the entire program has been converted to null safety,
some parts of the program are unsound. This unsoundness
can propagate into otherwise null-safe libraries and
cause non-nullable expressions to end up being `null` anyway.

The behavior of some language operations also change in
unsound mode. For example, the `as` check allows `null`,
even in null-safe libraries.

The functionality in this package is intended to check for
such situations in a way that is **recognizable**,
so that when the workarunds are no longer needed,
when the entire program has been made null safe,
they extra checks will be easy to find and remove.
