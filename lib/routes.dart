import 'package:aware_plus/views/glossary_view.dart';
import 'package:aware_plus/views/home_view.dart';
import 'package:aware_plus/views/knowledge_view.dart';
import 'package:aware_plus/views/login_view.dart';
import 'package:aware_plus/views/signup_view.dart';
import 'package:aware_plus/views/support_view.dart';
import 'package:aware_plus/views/welcome_view.dart';
import 'package:flutter/material.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (_) => WelcomeView(),
  '/signup': (_) => SignupView(),
  '/login': (_) => LoginView(),
  '/home': (_) => HomeView(),
  '/knowledge': (_) => KnowledgeView(),
  '/support' : (_) => SupportView(),
  '/glossary' : (_) => GlossaryView(),
};