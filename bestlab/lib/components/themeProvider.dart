import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData;
  bool _isDarkMode;

  ThemeProvider({required bool isDarkMode})
      : _isDarkMode = isDarkMode,
        _themeData = isDarkMode ? _darkTheme : _lightTheme;

  static final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    appBarTheme: AppBarTheme(
      color: Color.fromRGBO(75, 117, 198, 1),
    ),
  );

  static final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blueGrey,
    appBarTheme: AppBarTheme(
      color: Colors.blueGrey[900],
    ),
  );

  bool get isDarkMode => _isDarkMode;

  ThemeData get themeData => _themeData;

  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    _themeData = _isDarkMode ? _darkTheme : _lightTheme;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  Future<void> loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _themeData = _isDarkMode ? _darkTheme : _lightTheme;
    notifyListeners();
  }

  static ThemeProvider of(BuildContext context) {
    return context.watch<ThemeProvider>();
  }
}
