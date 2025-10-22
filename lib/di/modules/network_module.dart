
import 'package:injectable/injectable.dart';
import 'package:todo_village_mobile/common/helpers/dio_helper.dart';
import 'package:todo_village_mobile/di/providers/dio_provider.dart';

@module
abstract class NetworkModule {
  @lazySingleton
  DioHelper provideDioHelper(DioProvider dioProvider) {
    return DioHelper(dio: dioProvider.getDio());
  }
}
