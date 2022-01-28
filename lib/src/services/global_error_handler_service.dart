import 'package:flutter/widgets.dart';
import 'package:kakeibo_ui/src/exceptions/http_request_exception.dart';
import 'package:kakeibo_ui/src/exceptions/not_logged_in_exception.dart';
import 'package:kakeibo_ui/src/exceptions/signature_expired_exception.dart';
import 'package:kakeibo_ui/src/services/locator.dart';
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

    debugPrint(
        "(global_error_handler_service.dart) Exception caught in '_handleException'. Message: ${err.toString()}, type: ${err.runtimeType}");

    // TODO: Maybe a better way to handle token related exceptions is to just trigger the snackbar
    //       and the navigation (to the login view) here, and only signal onTokenRemoved for
    //       manual logouts. This way, all the exceptions are managed here, and it's easier to
    //       manage what happens when the user's token is removed (there are no multiple cases
    //       where the snackbar must be either displayed or not displayed).

    // TODO: All cases are the same. Refactor?
    switch (err.runtimeType) {
      case HttpRequestException:
        serviceLocator.get<SnackbarService>().simpleSnackbar(err.toString());
        break;
      case NotLoggedInException:
        serviceLocator.get<SnackbarService>().simpleSnackbar(err.toString());
        break;
      case SignatureExpiredException:
        serviceLocator.get<SnackbarService>().simpleSnackbar(err.toString());
        break;
      default:
        serviceLocator.get<SnackbarService>().simpleSnackbar(err.toString());
    }
  }
}
