import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_theme.dart';

/* 毛玻璃的颜色 黑夜 */
const Color glassDarkColor = Color.fromARGB(120, 0, 0, 0);

/* 毛玻璃的颜色 */
const Color glassColor = Color.fromARGB(100, 255, 255, 255);

final builtInThemes = [
  AppTheme(
    name: "TikTok",
    brightness: Brightness.dark,
    primary: Color(0xFF0D0D11),
    onPrimary: Colors.white,
    secondary: Colors.cyanAccent,
    onSecondary: Color(0xFF202222),
    surface: Color(0xFF0D0D11),
    onSurface: Colors.grey.shade400,
    error: Colors.redAccent,
    onError: Colors.white,
    themeMode: ThemeMode.light,
    shadowColor: glassDarkColor,
    isDefault: true,
  ),

  AppTheme(
    name: "BrightBlue",
    brightness: Brightness.light,
    primary: Colors.blue.shade700,
    onPrimary: Colors.white,
    secondary: Colors.lightBlueAccent,
    onSecondary: Colors.black,
    surface: Colors.grey.shade100,
    onSurface: Colors.black87,
    error: Colors.red,
    onError: Colors.white,
    isDefault: false,
    themeMode: ThemeMode.light,
    shadowColor: glassDarkColor,
  ),

  AppTheme(
    name: "PinkMinimal",
    brightness: Brightness.light,
    primary: Colors.pink.shade400,
    onPrimary: Colors.white,
    secondary: Colors.pinkAccent.shade100,
    onSecondary: Colors.black,
    surface: Colors.white,
    onSurface: Colors.black87,
    error: Colors.red.shade400,
    onError: Colors.white,
    isDefault: false,
    themeMode: ThemeMode.light,
    shadowColor: glassDarkColor,
  ),

  AppTheme(
    name: "DarkPurple",
    brightness: Brightness.dark,
    primary: Colors.deepPurple.shade800,
    onPrimary: Colors.white,
    secondary: Colors.purpleAccent,
    onSecondary: Colors.white,
    surface: Colors.grey.shade900,
    onSurface: Colors.white,
    error: Colors.red.shade400,
    onError: Colors.white,
    isDefault: false,
    themeMode: ThemeMode.light,
    shadowColor: glassDarkColor,
  ),

  AppTheme(
    name: "ModernGreen",
    brightness: Brightness.light,
    primary: Colors.green.shade700,
    onPrimary: Colors.white,
    secondary: Colors.lightGreenAccent,
    onSecondary: Colors.black,
    surface: Colors.green.shade50,
    onSurface: Colors.black87,
    error: Colors.red.shade400,
    onError: Colors.white,
    isDefault: false,
    themeMode: ThemeMode.light,
    shadowColor: glassDarkColor,
  ),
];

final apiThemeProvider = FutureProvider<List<AppTheme>>((ref) async {
  // final response = await http.get(Uri.parse('https://example.com/app_theme.json'));
  // if (response.statusCode == 200) {
  //   final List<dynamic> data = json.decode(response.body);
  //   return data.map((e) => AppTheme.fromJson(e)).toList();
  // }
  return [];
});

final currentThemeProvider = StateProvider<AppTheme>((ref) {
  // 初始值：优先API默认主题，否则内置默认主题
  final apiThemesAsync = ref.watch(apiThemeProvider);

  return apiThemesAsync.maybeWhen(
    data: (apiThemes) => apiThemes.firstWhere(
      (t) => t.isDefault,
      orElse: () => builtInThemes.firstWhere((t) => t.isDefault),
    ),
    orElse: () => builtInThemes.firstWhere((t) => t.isDefault),
  );
});
