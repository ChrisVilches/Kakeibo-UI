import 'package:get_it/get_it.dart';
import 'package:kakeibo_ui/src/services/graphql_services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kakeibo_ui/src/services/user_service.dart';

final serviceLocator = GetIt.instance;

void setUpLocator() {
  serviceLocator
      .registerLazySingleton<GraphQLServices>(() => GraphQLServices());

  serviceLocator.registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage());

  serviceLocator.registerLazySingleton<UserService>(() => UserService());
}
