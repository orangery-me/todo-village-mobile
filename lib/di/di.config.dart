// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter/cupertino.dart' as _i719;
import 'package:flutter/material.dart' as _i409;
import 'package:get_it/get_it.dart' as _i174;
import 'package:hive/hive.dart' as _i979;
import 'package:hive_flutter/hive_flutter.dart' as _i986;
import 'package:injectable/injectable.dart' as _i526;
import 'package:todo_village_mobile/common/helpers/dio_helper.dart' as _i652;
import 'package:todo_village_mobile/data/datasources/user/local/user_datasource.dart'
    as _i885;
import 'package:todo_village_mobile/data/datasources/user/remote/user_datasource.dart'
    as _i82;
import 'package:todo_village_mobile/data/datasources/user/user_datasource.dart'
    as _i896;
import 'package:todo_village_mobile/data/repositories/user_repository.dart'
    as _i6;
import 'package:todo_village_mobile/di/modules/local_module.dart' as _i673;
import 'package:todo_village_mobile/di/modules/network_module.dart' as _i669;
import 'package:todo_village_mobile/di/providers/dio_provider.dart' as _i718;

// initializes the registration of main-scope dependencies inside of GetIt
Future<_i174.GetIt> initGetIt(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) async {
  final gh = _i526.GetItHelper(
    getIt,
    environment,
    environmentFilter,
  );
  final localModule = _$LocalModule();
  final networkModule = _$NetworkModule();
  gh.lazySingleton<_i719.GlobalKey<_i719.NavigatorState>>(
      () => localModule.navigatorKey);
  await gh.singletonAsync<_i986.Box<dynamic>>(
    () => localModule.authBox,
    instanceName: 'auth_box',
    preResolve: true,
  );
  gh.lazySingleton<_i885.UserLocalDataSource>(() => _i885.UserLocalDataSource(
      authBox: gh<_i979.Box<dynamic>>(instanceName: 'auth_box')));
  gh.lazySingleton<_i718.DioProvider>(() => _i718.DioProvider(
        gh<_i979.Box<dynamic>>(instanceName: 'auth_box'),
        gh<_i409.GlobalKey<_i409.NavigatorState>>(),
      ));
  gh.lazySingleton<_i652.DioHelper>(
      () => networkModule.provideDioHelper(gh<_i718.DioProvider>()));
  gh.lazySingleton<_i82.UserRemoteDataSource>(
      () => _i82.UserRemoteDataSource(dioHelper: gh<_i652.DioHelper>()));
  gh.lazySingleton<_i896.UserDataSource>(() => _i896.UserDataSource(
        remoteDataSource: gh<_i82.UserRemoteDataSource>(),
        localDataSource: gh<_i885.UserLocalDataSource>(),
      ));
  gh.lazySingleton<_i6.UserRepository>(
      () => _i6.UserRepository(dataSource: gh<_i896.UserDataSource>()));
  return getIt;
}

class _$LocalModule extends _i673.LocalModule {}

class _$NetworkModule extends _i669.NetworkModule {}
