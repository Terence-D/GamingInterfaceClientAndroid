import 'dart:collection';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gic_flutter/model/channel.dart';
import 'package:gic_flutter/model/intl/localizations.dart';
import 'package:gic_flutter/views/main/mainPresentation.dart';
import 'package:gic_flutter/views/main/mainVM.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockViewContract implements MainViewContract {
  bool loadCompleted = false;
  bool showedPasswordError = false;
  bool showedAddressError = false;
  bool showedPortError = false;

  @override
  void onLoadComplete(MainVM viewModel) {
    loadCompleted = true;
  }

  @override
  void setConnectingIndicator(bool show) {
  }

  @override
  void showMessage(String message) {
    if (message == Intl.mainPasswordError)
      showedPasswordError = true;
    else if (message == Intl.mainInvalidPort)
      showedPortError = true;
    else if (message == Intl.mainInvalidServerError)
      showedAddressError = true;
  }

}

void main() {
  MethodChannel channel = const MethodChannel(Channel.channelView);
  MethodChannel channelUtil = const MethodChannel(Channel.channelUtil);
  MockViewContract mockContract = new MockViewContract();
  MainVM model = new MainVM();
  bool startedNewActivity = false;
  MainPresentation pres;
  
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    pres = new MainPresentation(mockContract);
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == Channel.actionViewStart) {
        startedNewActivity = true;
        return "started";
      }
      LinkedHashMap result = new LinkedHashMap<String, String>();
      return result;
    });
    channelUtil.setMockMethodCallHandler((MethodCall methodCall) async {
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

  test('after preferences are loaded it calls the view loaded', () async {
    //Assign

    //Act
    pres.preferencesLoaded(model);

    //Assert
    expect (true, mockContract.loadCompleted);
  });

  group('startGame', () {
    test('show error if password is too short', () async {
      //Assign
      MockViewContract mockContract = new MockViewContract();
      MainPresentation pres = new MainPresentation(mockContract);

      //Act
      await pres.startGame("1", "address", "1234", 1);

      //Assert
      expect (true, mockContract.showedPasswordError);
    });

    test('show error if password is null', () async {
      //Assign
      MockViewContract mockContract = new MockViewContract();
      MainPresentation pres = new MainPresentation(mockContract);

      //Act
      await pres.startGame(null, "address", "1234", 1);

      //Assert
      expect (true, mockContract.showedPasswordError);
    });

    test('show error if address is empty', () async {
      //Assign
      MockViewContract mockContract = new MockViewContract();
      MainPresentation pres = new MainPresentation(mockContract);

      //Act
      await pres.startGame("123456", "", "1234", 1);

      //Assert
      expect (true, mockContract.showedAddressError);
    });

    test('show error if address is null', () async {
      //Assign
      MockViewContract mockContract = new MockViewContract();
      MainPresentation pres = new MainPresentation(mockContract);

      //Act
      await pres.startGame("123456", null, "1234", 1);

      //Assert
      expect (true, mockContract.showedAddressError);
    });

    test('show error if port is not a number', () async {
      //Assign
      MockViewContract mockContract = new MockViewContract();
      MainPresentation pres = new MainPresentation(mockContract);

      //Act
      await pres.startGame("123456", "asdf", "asdf", 1);

      //Assert
      expect (true, mockContract.showedPortError);
    });

    test('show error if port is null', () async {
      //Assign
      MockViewContract mockContract = new MockViewContract();
      MainPresentation pres = new MainPresentation(mockContract);

      //Act
      await pres.startGame("123456", "asdf", null, 1);

      //Assert
      expect (true, mockContract.showedPortError);
    });

    test('load game view if all is valid', () async {
      //Assign
      MockViewContract mockContract = new MockViewContract();
      MainPresentation pres = new MainPresentation(mockContract);
      SharedPreferences.setMockInitialValues({}); //set values here

      //Act
      await pres.loadViewModel();
      await pres.startGame("123456", "asdf", "4", 1);

     //Assert
      expect(true, startedNewActivity);
    });
  });

}