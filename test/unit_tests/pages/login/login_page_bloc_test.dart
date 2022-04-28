import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartphone_app/helpers/app_values_helper.dart';
import 'package:smartphone_app/pages/login/login_page_bloc.dart';
import 'package:smartphone_app/pages/login/login_page_events_states.dart';
import 'package:smartphone_app/services/webservices/spotify/models/spotify_classes.dart';
import 'package:smartphone_app/services/webservices/spotify/services/spotify_service.dart';
import 'package:smartphone_app/utilities/general_util.dart';

import '../../../mocks/app_values_helper.dart';
import '../../../mocks/build_context.dart';
import '../../../mocks/permissions_helper.dart';
import '../../../mocks/spotify_service.dart';

class MockSpotifyServiceErrorModified extends MockSpotifyServiceError {
  @override
  Future<SpotifySdkResponseWithResult<String>> getAuthenticationToken() async {
    return SpotifySdkResponseWithResult.success("1234");
  }
}

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  group("LoginPage", () {
    late LoginPageBloc bloc;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      AppValuesHelper.getInstance().setup();
      bloc = LoginPageBloc(
          context: MockBuildContext(),
          permissionHelper: MockGrantedPermissionHelper());
    });

    group("SpotifyService -> Return error", () {
      setUp(() {
        SpotifyService.init(MockSpotifyServiceError());
      });

      blocTest<LoginPageBloc, LoginPageState>(
          "ButtonPressed -> Continue with Spotify",
          build: () => bloc,
          act: (bloc) => bloc.add(const ButtonPressed(
              buttonEvent: LoginButtonEvent.continueWithSpotify)),
          expect: () => []);

      blocTest<LoginPageBloc, LoginPageState>(
          "ButtonPressed -> Continue with Spotify -> getAuthenticationToken gives success",
          setUp: () => SpotifyService.init(MockSpotifyServiceErrorModified()),
          build: () => bloc,
          act: (bloc) => bloc.add(const ButtonPressed(
              buttonEvent: LoginButtonEvent.continueWithSpotify)),
          expect: () => []);
    });

    group("SpotifyService -> Return success", () {
      setUp(() {
        SpotifyService.init(MockSpotifyService());
      });

      test("Initial state is correct", () {
        expect(bloc.state,
            LoginPageState(permissionState: PermissionState.denied));
      });

      blocTest<LoginPageBloc, LoginPageState>("getPermissions method",
          build: () => bloc,
          act: (bloc) async => await bloc.getPermissions(),
          expect: () =>
              [bloc.state.copyWith(permissionState: PermissionState.granted)]);

      blocTest<LoginPageBloc, LoginPageState>(
          "ButtonPressed -> Continue with Spotify",
          setUp: () async {
            SharedPreferences.setMockInitialValues({});
            var sharedPreferences = await SharedPreferences.getInstance();
            AppValuesHelper.getInstance().sharedPreferences = sharedPreferences;
          },
          build: () => bloc,
          act: (bloc) => bloc.add(const ButtonPressed(
              buttonEvent: LoginButtonEvent.continueWithSpotify)),
          expect: () => []);

      blocTest<LoginPageBloc, LoginPageState>("ButtonPressed -> Go to settings",
          build: () => bloc,
          act: (bloc) => bloc.add(
              const ButtonPressed(buttonEvent: LoginButtonEvent.goToSettings)),
          expect: () => []);

      blocTest<LoginPageBloc, LoginPageState>("Resumed -> Permissions granted",
          build: () => bloc,
          act: (bloc) => bloc.add(const Resumed()),
          expect: () =>
              [bloc.state.copyWith(permissionState: PermissionState.granted)]);

      blocTest<LoginPageBloc, LoginPageState>("Resumed -> Permissions denied",
          setUp: () {
            bloc = LoginPageBloc(
                context: MockBuildContext(),
                permissionHelper: MockDeniedPermissionHelper());
          },
          build: () => bloc,
          act: (bloc) => bloc.add(const Resumed()),
          expect: () =>
              [bloc.state.copyWith(permissionState: PermissionState.denied)]);

      blocTest<LoginPageBloc, LoginPageState>(
          "PermissionsStateChanged -> Permissions granted",
          build: () => bloc,
          act: (bloc) => bloc.add(const PermissionStateChanged(
              permissionState: PermissionState.granted)),
          expect: () =>
              [bloc.state.copyWith(permissionState: PermissionState.granted)]);
    });
  });
}
