import 'package:equatable/equatable.dart';

abstract class AppFailure extends Equatable {
  final String message;
  final StackTrace? stackTrace;

  const AppFailure(this.message, [this.stackTrace]);

  @override
  List<Object?> get props => [message, stackTrace];
}

class StorageFailure extends AppFailure {
  const StorageFailure(super.message, [super.stackTrace]);
}

class ValidationFailure extends AppFailure {
  const ValidationFailure(super.message, [super.stackTrace]);
}

class NotFoundFailure extends AppFailure {
  const NotFoundFailure(super.message, [super.stackTrace]);
}
