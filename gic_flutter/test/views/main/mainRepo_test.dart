import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gic_flutter/model/channel.dart';
import 'package:gic_flutter/views/main/mainRepo.dart';
import 'package:gic_flutter/views/main/mainVM.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockRepoContract implements MainRepoContract {
  MainVM vm;
  bool called = false;

  void preferencesLoaded(MainVM viewModel) {
    vm = viewModel;
    called = true;
  }
}

void main() {
  MethodChannel channel = const MethodChannel(Channel.channelUtil);

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == Channel.actionUtilDecrypt) {
        return "test";
      }
      LinkedHashMap result = new LinkedHashMap<String, String>();
      //result.putIfAbsent("decrypt", () =>"ok");
      return result;
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });


  test('preferences loaded is called on fetch', () async {
    //Assign
    SharedPreferences.setMockInitialValues({}); //set values here
    MockRepoContract contract = new MockRepoContract();
    MainRepo repo = new MainRepo(contract);

    //Act
    await repo.fetch();

    //Assert
    expect(true, contract.called);
  });

  test('Preference legacyConvert becomes false on first run', () async {
    //Assign
    SharedPreferences.setMockInitialValues({}); //set values here
    MockRepoContract contract = new MockRepoContract();
    MainRepo repo = new MainRepo(contract);

    //Act
    await repo.fetch();

    //Assert
    SharedPreferences prefs = await SharedPreferences.getInstance();
    expect(false, prefs.get("legacyConvert"));
  });

  test('Preference legacyConvertScreens becomes false on first run', () async {
    //Assign

    SharedPreferences.setMockInitialValues({}); //set values here
    MockRepoContract contract = new MockRepoContract();
    MainRepo repo = new MainRepo(contract);

    //Act
    await repo.fetch();

    //Assert
    SharedPreferences prefs = await SharedPreferences.getInstance();
    expect(false, prefs.get("legacyConvertScreens"));
  });

  test('Password is set on fetch', () async {
    //Assign
    SharedPreferences.setMockInitialValues(<String, dynamic>{"password" : "testPassword"});

    MockRepoContract contract = new MockRepoContract();
    MainRepo repo = new MainRepo(contract);

    //Act
    await repo.fetch();

    //Assert
    expect("test", contract.vm.password);
  });

  test('on a new load, creates 1 empty screen', () async {
    //Assign
    SharedPreferences.setMockInitialValues({}); //set values here
    MockRepoContract contract = new MockRepoContract();
    MainRepo repo = new MainRepo(contract);

    //Act
    await repo.fetch();

    //Assert
    expect(1, contract.vm.screenList.length);
    expect("Empty Screen", contract.vm.screenList[0].name);
  });

  test('sets several variables on initial load', () async {
    //Assign
    SharedPreferences.setMockInitialValues({}); //set values here
    MockRepoContract contract = new MockRepoContract();
    MainRepo repo = new MainRepo(contract);

    //Act
    await repo.fetch();

    //Assert
    expect(true, contract.vm.darkMode);
    expect("8091", contract.vm.port);
    expect("192.168.x.x", contract.vm.address);
  });

  test('sets several variables based on prefs', () async {
    //Assign
    SharedPreferences.setMockInitialValues(<String, dynamic>{
      "nightMode" : false,
      "port" : "1234",
      "address" : "new",
    });
    MockRepoContract contract = new MockRepoContract();
    MainRepo repo = new MainRepo(contract);

    //Act
    await repo.fetch();

    //Assert
    expect(false, contract.vm.darkMode);
    expect("1234", contract.vm.port);
    expect("new", contract.vm.address);
  });

//  test('on new install need to ensure first run value is set', () {
//    //Assign
//    final List<MethodCall> log = <MethodCall>[];
//    MethodChannel channel = const MethodChannel('ca.coffeeshopstudio.gic/utils');
//
//    // Register the mock handler.
//    channel.setMockMethodCallHandler((MethodCall methodCall) async {
//      log.add(methodCall);
//    });
//
//    SharedPreferences.setMockInitialValues({}); //set values here
//    MockRepoContract contract = new MockRepoContract();
//    MainRepo repo = new MainRepo(contract);
//
//    //Act
//    repo.fetch();
//
//    //Assert
//    expect(true, contract.vm.firstRun);
//    //expect(log, equals(<MethodCall>[new MethodCall('settings/git', "http://example.com/")]));
//
//    // Unregister the mock handler.
//    channel.setMockMethodCallHandler(null);
//  });

//  test('on old install first run should be false', () {
//    //Assign
//    SharedPreferences.setMockInitialValues(<String, dynamic>{_prefixedKey: false});
//
//
//    MockRepoContract contract = new MockRepoContract();
//    MainRepo repo = new MainRepo(contract);
//
//    //Act
//    repo.fetch();
//
//    //Assert
//    expect(true, contract.vm.firstRun);
//  });
}