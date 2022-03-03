import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartphone_app/pages/login/login_events_states.dart';

class LoginPageBloc extends Bloc<LoginPageEvent, LoginPageState> {
  ///
  /// VARIABLES
  ///
  //region Variables

  late BuildContext context;

  //endregion

  ///
  /// CONSTRUCTOR
  ///
  //region Constructor

  LoginPageBloc({required this.context}) : super(const LoginPageState()) {
    // ButtonPressed
    on<ButtonPressed>((event, emit) {
      print("test");
    });
  }

//endregion

  ///
  /// METHODS
  ///
//region Methods

//endregion

}
