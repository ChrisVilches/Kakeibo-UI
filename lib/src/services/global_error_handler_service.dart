import 'package:flutter/widgets.dart';
import 'package:kakeibo_ui/src/exceptions/http_request_exception.dart';
import 'package:kakeibo_ui/src/exceptions/not_logged_in_exception.dart';
import 'package:kakeibo_ui/src/exceptions/signature_expired_exception.dart';
import 'package:kakeibo_ui/src/services/snackbar_service.dart';

/// This class is a substitute for the error handling mechanism provided by 'runZonedGuarded'.
/// Since this method doesn't work for this application (errors aren't caught, for some reason),
/// use this to signal errors and handle them globally. Context is accessible as well, so
/// navigation and other things like snackbars can be used.
class GlobalErrorHandlerService {
  final GlobalKey<NavigatorState> _navigatorKey;

  GlobalErrorHandlerService(this._navigatorKey);

  void signalError(Exception err, {bool doThrow = false}) {
    _handleException(err);

    if (doThrow) {
      throw err;
    }
  }

  void _handleException(Exception err) {
    if (_navigatorKey.currentContext == null) return;

    BuildContext context = _navigatorKey.currentContext!;

    switch (err.runtimeType) {
      case HttpRequestException:
        SnackbarService.simpleSnackbar(context, err.toString());
        break;
      case NotLoggedInException:
        SnackbarService.simpleSnackbar(context, err.toString());
        break;
      case SignatureExpiredException:
        SnackbarService.simpleSnackbar(context, err.toString());
    }
  }
}
