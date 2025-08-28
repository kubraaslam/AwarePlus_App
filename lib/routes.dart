
import 'package:aware_plus/views/appointments_view.dart';
import 'package:aware_plus/views/book_appointment_view.dart';
import 'package:aware_plus/views/counselor_dashboard.dart';
import 'package:aware_plus/views/create_events_view.dart';
import 'package:aware_plus/views/emergency_view.dart';
import 'package:aware_plus/views/events_view.dart';
import 'package:aware_plus/views/glossary_view.dart';
import 'package:aware_plus/views/home_view.dart';
import 'package:aware_plus/views/knowledge_view.dart';
import 'package:aware_plus/views/login_view.dart';
import 'package:aware_plus/views/notes_view.dart';
import 'package:aware_plus/views/profile_view.dart';
import 'package:aware_plus/views/signup_view.dart';
import 'package:aware_plus/views/support_view.dart';
import 'package:aware_plus/views/week_availability.dart';
import 'package:aware_plus/views/welcome_view.dart';
import 'package:flutter/material.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (_) => WelcomeView(),
  '/signup': (_) => SignupView(),
  '/login': (_) => LoginView(),
  '/home': (_) => HomeView(),
  '/knowledge': (_) => KnowledgeView(),
  '/support': (_) => SupportView(),
  '/glossary': (_) => GlossaryView(),
  '/emergency': (_) => EmergencyView(),
  '/profile': (_) => ProfileView(),
  '/counselorProfile' : (_) => ProfileView(useCounselorNav: true),
  '/counselorDashboard': (_) => CounselorDashboard(),
  '/bookAppointment': (_) => BookAppointmentPage(counselorId: '5JBRZ1SxjeYDpGxrmJogOQHsISb2',),
  '/myAppointments' : (_) => MyAppointmentsView(),
  '/counselorNotes' : (_) => PastNotesPage(),
  '/availability' : (_) => WeeklyAvailabilityScreen(),
  '/createEvents' : (_) => CounselorEventsPage(),
  '/events' : (_) => StudentEventsPage()
};
