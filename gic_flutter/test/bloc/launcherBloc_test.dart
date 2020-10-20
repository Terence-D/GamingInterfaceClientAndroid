import 'package:flutter_test/flutter_test.dart';
import 'package:gic_flutter/bloc/launcherBloc.dart';
import 'package:gic_flutter/resources/launcherRepository.dart';
import 'package:mockito/mockito.dart';

class MockLauncherRepository extends Mock implements LauncherRepository {}

void main() {
  MockLauncherRepository mockedRepo = new MockLauncherRepository();

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    mockedRepo = new MockLauncherRepository();
  });

  test('saving main calls the matching repo method', () async {
    //Assign
    LauncherBloc toTest = new LauncherBloc.withMocks(mockedRepo);

    //Act
    toTest.saveConnectionSettings("password", "port", "address");

    //Assert
    verify(mockedRepo.saveMainSettings("password", "port", "address")).called(1);

  });

  test('setting theme calls the matching repo method', () async {
    //Assign
    LauncherBloc toTest = new LauncherBloc.withMocks(mockedRepo);

    //Act
    toTest.setTheme(true);

    //Assert
    verify(mockedRepo.setDarkMode(true)).called(1);
  });

  test('calling newscreen returns the screen id', () async {
    //Assign
    LauncherBloc toTest = new LauncherBloc.withMocks(mockedRepo);
    when(mockedRepo.newScreen()).thenAnswer((_) async => 1);

    //Act
    int rv = await toTest.newScreen();

    //Assert
    expect(rv, 1);
  });

  test('calling newscreen calls fetch preferences', () async {
    //Assign
    LauncherBloc toTest = new LauncherBloc.withMocks(mockedRepo);
    when(mockedRepo.newScreen()).thenAnswer((_) async => 1);

    //Act
    int rv = await toTest.newScreen();

    //Assert
    verify(mockedRepo.newScreen()).called(1);
  });

  test('updating the name calls the matching repo method', () async {
    //Assign
    LauncherBloc toTest = new LauncherBloc.withMocks(mockedRepo);

    //Act
    toTest.updateScreenName(1, "newName");

    //Assert
    verify(mockedRepo.updateName(1, "newName")).called(1);
  });

  test('deleting a screen will return the new cache length', () async {
    //Assign
    LauncherBloc toTest = new LauncherBloc.withMocks(mockedRepo);
    when(mockedRepo.deleteScreen(1)).thenAnswer((_) async => 5);

    //Act
    int rv = await toTest.deleteScreen(1);

    //Assert
    expect (rv, 5);
  });

  test('deleting a screen will call matching repo method', () async {
    //Assign
    LauncherBloc toTest = new LauncherBloc.withMocks(mockedRepo);
    when(mockedRepo.deleteScreen(1)).thenAnswer((_) async => 5);

    //Act
    int rv = await toTest.deleteScreen(1);

    //Assert
    verify(mockedRepo.deleteScreen(1)).called(1);
  });

  test('deleting an invalid screen will return -1 for an error', () async {
    //Assign
    LauncherBloc toTest = new LauncherBloc.withMocks(mockedRepo);
    when(mockedRepo.deleteScreen(999)).thenAnswer((_) async => -1);

    //Act
    int rv = await toTest.deleteScreen(999);

    //Assert
    expect (rv, -1);
  });

  test('importing a screen will return an integer', () async {
    //Assign
    LauncherBloc toTest = new LauncherBloc.withMocks(mockedRepo);
    when(mockedRepo.import(999)).thenAnswer((_) async => 1);

    //Act
    int rv = await toTest.import(999);

    //Assert
    expect (rv, 1);
  });

  test('exporting a screen will return an integer', () async {
    //Assign
    LauncherBloc toTest = new LauncherBloc.withMocks(mockedRepo);
    when(mockedRepo.export("path", 1)).thenAnswer((_) async => 1);

    //Act
    int rv = await toTest.export("path", 1);

    //Assert
    expect (rv, 1);
  });
}