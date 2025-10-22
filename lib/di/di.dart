import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:todo_village_mobile/di/di.config.dart';

final getIt = GetIt.instance;

@InjectableInit(initializerName: 'initGetIt', asExtension: false)
Future<void> configureDependencies() => initGetIt(getIt);
