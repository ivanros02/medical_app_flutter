import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login Minimalista',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      initialRoute: '/', // Ruta inicial
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/home':
            return MaterialPageRoute(builder: (_) => HomeScreen());
          default:
            return MaterialPageRoute(
                builder: (_) =>
                    const LoginScreen()); // En caso de ruta desconocida, vuelve a la pantalla de login.
        }
      },
    );
  }
}
