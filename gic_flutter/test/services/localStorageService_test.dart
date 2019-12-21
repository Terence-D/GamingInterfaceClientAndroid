import 'package:flutter_test/flutter_test.dart';
import 'package:gic_flutter/services/localStorageService.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  test('first run is true on first run', () async {
    //Assign
    SharedPreferences.setMockInitialValues(<String, dynamic>{});
    LocalStorageService localStorageService = await LocalStorageService.getInstance();

    //Act

    //Assert
    expect (true, localStorageService.firstRun);
  });

  test('first run is false on later run', () async {
    //Assign
    SharedPreferences.setMockInitialValues(<String, dynamic>{
      "firstRun" : false,
    });
    LocalStorageService localStorageService = await LocalStorageService.getInstance();

    //Act

    //Assert
    expect (false, localStorageService.firstRun);
  });

}