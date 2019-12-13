import 'package:flutter_test/flutter_test.dart';
import 'package:gic_flutter/views/main/mainRepo.dart';
import 'package:gic_flutter/views/main/mainVM.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockRepoContract implements MainRepoContract {
  MainVM vm;

  void preferencesLoaded(MainVM viewModel) {
    vm = viewModel;
  }
}

void main() {
  test('on new install need to convert should be true', () {
    //Assign
    SharedPreferences.setMockInitialValues({}); //set values here
    MockRepoContract contract = new MockRepoContract();
    MainRepo repo = new MainRepo(contract);

    //Act
    repo.fetch();

    //Assert
    expect(true, contract.vm.firstRun);
  });

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