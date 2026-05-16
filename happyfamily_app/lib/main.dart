import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/family_provider.dart';
import 'screens/login_screen.dart';
import 'screens/map_screen.dart';
import 'screens/family_setup_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HappyFamilyApp());
}

class HappyFamilyApp extends StatelessWidget {
  const HappyFamilyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProvider(create: (_) => FamilyProvider()),
      ],
      child: MaterialApp(
        title: 'HappyFamily',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4CAF50)),
          useMaterial3: true,
          fontFamily: 'SF Pro Display',
        ),
        home: const _RootNavigator(),
      ),
    );
  }
}

class _RootNavigator extends StatelessWidget {
  const _RootNavigator();

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthProvider>().state;
    final user = context.watch<AuthProvider>().user;

    switch (authState) {
      case AuthState.initial:
      case AuthState.loading:
        return const Scaffold(
          body: Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50))),
        );
      case AuthState.unauthenticated:
        return const LoginScreen();
      case AuthState.authenticated:
        // If user has no family yet, show setup screen
        if (user?.familyId == null) {
          return const FamilySetupScreen();
        }
        return const MapScreen();
    }
  }
}
