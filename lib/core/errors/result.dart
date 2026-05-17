import 'failures.dart';

/// Repository'lerden dönen sonuçlar için sealed tip.
///
/// Kullanım:
/// ```
/// final result = await repo.fetchJob(id);
/// switch (result) {
///   case Success(:final value):  ...
///   case ResultFailure(:final failure):  ...
/// }
/// ```
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is ResultFailure<T>;

  T? get valueOrNull => switch (this) {
        Success(:final value) => value,
        ResultFailure() => null,
      };

  AppFailure? get failureOrNull => switch (this) {
        Success() => null,
        ResultFailure(:final failure) => failure,
      };

  R when<R>({
    required R Function(T value) success,
    required R Function(AppFailure failure) failure,
  }) {
    return switch (this) {
      Success<T>(value: final v) => success(v),
      ResultFailure<T>(failure: final f) => failure(f),
    };
  }
}

final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

final class ResultFailure<T> extends Result<T> {
  const ResultFailure(this.failure);
  final AppFailure failure;
}
