import 'package:flutter_test/flutter_test.dart';
import 'package:gic_flutter/views/main/mainRepo.dart';
import 'package:gic_flutter/views/main/mainVM.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockRepoContract implements MainRepoContract {
  MainVM vm;

  void preferencesLoaded(MainVM viewModel) {
    vm = viewModel;
  }
}

void main() {
  test('prefs should be initialized on fetch', () {
    //Assign
    SharedPreferences.setMockInitialValues({}); //set values here
    MockRepoContract contract = new MockRepoContract();
    MainRepo repo = new MainRepo(contract);

    //Act
    repo.fetch();

    //Assert
    expect(true, contract.vm.firstRun);
  });
}