import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/booking_provider.dart';
import 'screens/dashboard_screen.dart';

const Color _navy = Color(0xFF0B1F3A);
const Color _canvas = Color(0xFFF4F7FB);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HotelBookingApp());
}

class HotelBookingApp extends StatelessWidget {
  const HotelBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          BookingProvider(enableLocalStorage: true)..loadSavedBookings(),
      child: MaterialApp(
        title: 'Hotel Room Booking',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: _canvas,
          colorScheme: ColorScheme.fromSeed(
            seedColor: _navy,
            primary: _navy,
            surface: Colors.white,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: _navy,
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
          radioTheme: RadioThemeData(
            fillColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return _navy;
              }
              return const Color(0xFF94A3B8);
            }),
          ),
          datePickerTheme: DatePickerThemeData(
            backgroundColor: Colors.white,
            headerBackgroundColor: _navy,
            headerForegroundColor: Colors.white,
            todayForegroundColor: const WidgetStatePropertyAll(_navy),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        home: const DashboardScreen(),
      ),
    );
  }
}
