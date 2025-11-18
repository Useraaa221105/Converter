import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/length_conversion_screen.dart';
import 'screens/area_conversion_screen.dart';
import 'screens/speed_conversion_screen.dart';
import 'screens/mass_conversion_screen.dart';
import 'screens/temperature_conversion_screen.dart';
import 'screens/volume_conversion_screen.dart';

void main() => runApp(const UnitConverterApp());

class UnitConverterApp extends StatelessWidget {
  const UnitConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/length': (context) => const LengthConversionScreen(),
        '/area': (context) => const AreaConversionScreen(),
        '/speed': (context) => const SpeedConversionScreen(),
        '/mass': (context) => const MassConversionScreen(),
        '/temperature': (context) => const TemperatureConversionScreen(),
        '/volume': (context) => const VolumeConversionScreen(),
      },
    );
  }
}
