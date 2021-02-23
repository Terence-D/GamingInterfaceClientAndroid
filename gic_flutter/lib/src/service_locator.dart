import 'package:get_it/get_it.dart';

import 'backend/services/firstRunService.dart';

GetIt locator = GetIt.instance;

Future setupLocator() async {
  var instance = await FirstRunService.getInstance();
  locator.registerSingleton<FirstRunService>(instance);
}