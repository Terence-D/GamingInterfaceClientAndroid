import 'dart:collection';

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
      if (methodCall.method == Channel.actionUtilEncrypt) {
        return "password";
      }
      if (methodCall.method == Channel.actionUtilUpdateDarkMode) {
        return true;
      }
      LinkedHashMap result = new LinkedHashMap<String, String>();
      return result;
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  group('Fetch', () {
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

    test('will not show the donation icons if no donation made', () async {
      //Assign
      SharedPreferences.setMockInitialValues({}); //set values here
      MockRepoContract contract = new MockRepoContract();
      MainRepo repo = new MainRepo(contract);

      //Act
      await repo.fetch();

      //Assert
      expect(false, contract.vm.donate);
      expect(false, contract.vm.donateStar);
    });

    test('will show donation icon if donation made', () async {
      //Assign
      SharedPreferences.setMockInitialValues(<String, dynamic>{
        "coffee" : true,
      });
      MockRepoContract contract = new MockRepoContract();
      MainRepo repo = new MainRepo(contract);

      //Act
      await repo.fetch();

      //Assert
      expect(true, contract.vm.donate);
      expect(false, contract.vm.donateStar);
    });

    test('will show donation star icon if bigger donation made', () async {
      //Assign
      SharedPreferences.setMockInitialValues(<String, dynamic>{
        "star" : true,
      });
      MockRepoContract contract = new MockRepoContract();
      MainRepo repo = new MainRepo(contract);

      //Act
      await repo.fetch();

      //Assert
      expect(false, contract.vm.donate);
      expect(true, contract.vm.donateStar);
    });
  });

  group('SaveSettings', () {
    test('values passed in are saved', () async {
      //Assign
      SharedPreferences.setMockInitialValues({}); //set values here
      MockRepoContract contract = new MockRepoContract();
      MainRepo repo = new MainRepo(contract);

      //Act
      await repo.fetch();
      await repo.saveMainSettings("address", "234", "password", 5);

      //Assert
      expect("address", contract.vm.address);
      expect("234", contract.vm.port);
      expect("password", contract.vm.password);
    });

    test('values passed in are maintained between fetches', () async {
      //Assign
      SharedPreferences.setMockInitialValues({}); //set values here
      MockRepoContract contract = new MockRepoContract();
      MainRepo repo = new MainRepo(contract);

      //Act
      await repo.fetch();
      await repo.saveMainSettings("address", "234", "test", 5);
      await repo.fetch();

      //Assert
      expect("address", contract.vm.address);
      expect("234", contract.vm.port);
      expect("test", contract.vm.password);
    });

    test('handles null gracefully', () async {
      //Assign
      SharedPreferences.setMockInitialValues({}); //set values here
      MockRepoContract contract = new MockRepoContract();
      MainRepo repo = new MainRepo(contract);

      //Act
      await repo.fetch();
      await repo.saveMainSettings(null, null, null, 5);

      //Assert
      expect("192.168.x.x", contract.vm.address);
      expect("8091", contract.vm.port);
      expect("", contract.vm.password);
    });

    test('handles empty strings gracefully', () async {
      //Assign
      SharedPreferences.setMockInitialValues({}); //set values here
      MockRepoContract contract = new MockRepoContract();
      MainRepo repo = new MainRepo(contract);

      //Act
      await repo.fetch();
      await repo.saveMainSettings('', '', '', 5);

      //Assert
      expect("192.168.x.x", contract.vm.address);
      expect("8091", contract.vm.port);
      expect("", contract.vm.password);
    });

    test('only updates port when numeric', () async {
      //Assign
      SharedPreferences.setMockInitialValues({}); //set values here
      MockRepoContract contract = new MockRepoContract();
      MainRepo repo = new MainRepo(contract);

      //Act
      await repo.fetch();
      await repo.saveMainSettings('', 'asdf', '', 5);

      //Assert
      expect("8091", contract.vm.port);
    });

    test('saves screen id to preferences', () async {
      //Assign
      SharedPreferences.setMockInitialValues({}); //set values here
      MockRepoContract contract = new MockRepoContract();
      MainRepo repo = new MainRepo(contract);
      SharedPreferences prefs = await SharedPreferences.getInstance();

      //Act
      await repo.fetch();
      await repo.saveMainSettings('', '', '', 5);

      //Assert
      expect(5, prefs.get("chosenId"));
    });
  });

  group ("setDarkMode", () {
    test('toggles dark mode', () async {
      //Assign
      SharedPreferences.setMockInitialValues({}); //set values here
      MockRepoContract contract = new MockRepoContract();
      MainRepo repo = new MainRepo(contract);

      //Act
      await repo.fetch();
      await repo.setDarkMode(false);

      //Assert
      expect(false, contract.vm.darkMode);
    });

    test('retains dark mode after fetching', () async {
      //Assign
      SharedPreferences.setMockInitialValues({}); //set values here
      MockRepoContract contract = new MockRepoContract();
      MainRepo repo = new MainRepo(contract);

      //Act
      await repo.fetch();
      await repo.setDarkMode(false);
      await repo.fetch();

      //Assert
      expect(false, contract.vm.darkMode);
    });
  });

}