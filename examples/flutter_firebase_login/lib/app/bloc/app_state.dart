part of 'app_bloc.dart';

enum AppStatus {
  authenticated,
  unauthenticated,
}

final class AppState extends Equatable {
  @visibleForTesting
  const AppState({
    required this.status,
    this.user = User.empty,
  });

  factory AppState.fromUser(User user) {
    return user.isNotEmpty
        ? AppState(status: AppStatus.authenticated, user: user)
        : const AppState(status: AppStatus.unauthenticated);
  }

  final AppStatus status;
  final User user;

  @override
  List<Object> get props => [status, user];
}
