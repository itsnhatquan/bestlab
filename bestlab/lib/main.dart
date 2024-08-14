import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bestlab/components/themeProvider.dart';
import 'package:bestlab/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeProvider = ThemeProvider(isDarkMode: false);
  await themeProvider.loadThemePreference();

  runApp(
    ChangeNotifierProvider(
      create: (_) => themeProvider,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      theme: themeProvider.themeData,
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
