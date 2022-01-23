import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:kakeibo_ui/src/services/global_error_handler_service.dart';
import 'package:kakeibo_ui/src/services/gql_client.dart';
import 'package:kakeibo_ui/src/services/snackbar_service.dart';
import 'package:kakeibo_ui/src/services/user_service.dart';

final serviceLocator = GetIt.instance;

void setUpLocator(GlobalKey<NavigatorState> navigatorKey) {
  serviceLocator.registerLazySingleton<GQLClient>(() => GQLClient());

  serviceLocator.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());

  serviceLocator.registerLazySingleton<UserService>(() => UserService());

  serviceLocator.registerLazySingleton<GlobalErrorHandlerService>(
      () => GlobalErrorHandlerService(navigatorKey));

  serviceLocator.registerSingleton<SnackbarService>(SnackbarService(navigatorKey));
}
