import 'package:get_it/get_it.dart';
import 'package:gic_flutter/services/localStorageService.dart';

GetIt locator = GetIt();

Future setupLocator() async {
  var instance = await LocalStorageService.getInstance();
  locator.registerSingleton<LocalStorageService>(instance);
}