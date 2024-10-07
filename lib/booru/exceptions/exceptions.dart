class FeatureUnavailable implements Exception {
  FeatureUnavailable() {throw('FeatureUnavailable');}
}

class ArgumentNullException implements Exception {
  ArgumentNullException([String? value]) {throw ('ArgumentNullException $value');}
}

class ArgumentException implements Exception {
  ArgumentException([String? value]) {throw ('ArgumentException: $value');}
}

class InvalidTags implements Exception {
  InvalidTags([String? value]) {throw ('InvalidTags: $value');}
}


class TooManyTags implements Exception {
  /// Initializes a new instance of the [TooManyTags] class with a specified
  /// error message and a reference to the inner exception that is the cause of this exception.
  /// [message] The error message that explains the reason for the exception.
  /// [innerException] The exception that is the cause of the current exception,
  /// or a "langword="null" reference if no inner exception is specified.
  TooManyTags([String? message, Exception? innerException]) : super(/*message, innerException*/);

}