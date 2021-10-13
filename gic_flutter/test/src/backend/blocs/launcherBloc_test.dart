import 'package:flutter_test/flutter_test.dart';
import 'package:gic_flutter/src/backend/blocs/launcherBloc.dart';
import 'package:gic_flutter/src/backend/models/networkModel.dart';
import 'package:gic_flutter/src/backend/repositories/launcherRepository.dart';
import 'package:mockito/mockito.dart';

class MockLauncherRepository extends Mock implements LauncherRepository {}

void main() {
  MockLauncherRepository mockedRepo = MockLauncherRepository();

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    mockedRepo = MockLauncherRepository();
  });

  test('saving main calls the matching repo method', () async {
    //Assign
    LauncherBloc toTest = LauncherBloc.withMocks(mockedRepo);
    NetworkModel networkModel = NetworkModel();
    networkModel.toTest("password", "address", "port");

    //Act
    toTest.saveConnectionSettings(networkModel);

    //Assert
    verify(mockedRepo.saveMainSettings(networkModel)).called(1);

  });

  test('setting theme calls the matching repo method', () async {
    //Assign
    LauncherBloc toTest = LauncherBloc.withMocks(mockedRepo);

    //Act
    toTest.setTheme(true);

    //Assert
    verify(mockedRepo.setDarkMode(true)).called(1);
  });

  test('updating the name calls the matching repo method', () async {
    //Assign
    LauncherBloc toTest = LauncherBloc.withMocks(mockedRepo);

    //Act
    await toTest.updateScreenName(1, "newName");

    //Assert
    verify(mockedRepo.updateName(1, "newName")).called(1);
  });

  test('deleting a screen will return the new cache length', () async {
    //Assign
    LauncherBloc toTest = LauncherBloc.withMocks(mockedRepo);
    when(mockedRepo.deleteScreen(1)).thenAnswer((_) async => 5);

    //Act
    int rv = await toTest.deleteScreen(1);

    //Assert
    expect (rv, 5);
  });

  test('deleting a screen will call matching repo method', () async {
    //Assign
    LauncherBloc toTest = LauncherBloc.withMocks(mockedRepo);
    when(mockedRepo.deleteScreen(1)).thenAnswer((_) async => 5);

    //Act
    await toTest.deleteScreen(1);

    //Assert
    verify(mockedRepo.deleteScreen(1)).called(1);
  });

  test('deleting an invalid screen will return -1 for an error', () async {
    //Assign
    LauncherBloc toTest = LauncherBloc.withMocks(mockedRepo);
    when(mockedRepo.deleteScreen(999)).thenAnswer((_) async => -1);

    //Act
    int rv = await toTest.deleteScreen(999);

    //Assert
    expect (rv, -1);
  });

  test('exporting a screen will return an integer', () async {
    //Assign
    LauncherBloc toTest = LauncherBloc.withMocks(mockedRepo);
    when(mockedRepo.export("path", 1)).thenAnswer((_) async => "1");

    //Act
    String rv = await toTest.export("path", 1);

    //Assert
    expect (rv, "1");
  });
}