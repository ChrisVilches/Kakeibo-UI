import 'package:get_it/get_it.dart';
import 'package:kakeibo_ui/src/services/graphql_services.dart';

final serviceLocator = GetIt.instance;

void setUpLocator() {
  serviceLocator
      .registerLazySingleton<GraphQLServices>(() => GraphQLServices());
}
