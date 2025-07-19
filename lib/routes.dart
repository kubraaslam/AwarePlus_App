import 'package:aware_plus/views/signup_view.dart';
import 'package:aware_plus/views/welcome_view.dart';
import 'package:flutter/material.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (_) => WelcomeView(),
  '/signup': (_) => SignupView(),
};