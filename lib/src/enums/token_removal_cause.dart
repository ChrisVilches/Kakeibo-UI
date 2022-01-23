enum TokenRemovalCause { manualLogout, sessionExpired, unknown }

extension TokenRemovalCauseExtension on TokenRemovalCause {
  String get message {
    switch (this) {
      case TokenRemovalCause.manualLogout:
        return 'You have logged out';
      case TokenRemovalCause.sessionExpired:
        return 'Your session has expired';
      default:
        return 'You are not logged in';
    }
  }
}
