import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/router/go_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://tqqyzwxhikysljtvxjhl.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRxcXl6d3hoaWt5c2xqdHZ4amhsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM0ODYyMDksImV4cCI6MjA3OTA2MjIwOX0.YJqcSpuXwo5R9xO3HuqFiGw7otiB7hXgi6eiZlFmsYs',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
