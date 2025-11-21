import 'package:flutter/material.dart';

class AppTheme {
  final String name;
  final Brightness brightness;
  final Color primary;
  final Color onPrimary;
  final Color secondary;
  final Color onSecondary;
  final Color surface;
  final Color onSurface;
  final Color error;
  final Color onError;
  final ThemeMode themeMode;
  final String? backgroundImage;
  final bool isDefault;
  final Color shadowColor;
  final TextTheme? textTheme; // 可选文字主题
  final double? elevation; // 默认阴影高度

  AppTheme({
    required this.name,
    required this.brightness,
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.onSecondary,
    required this.surface,
    required this.onSurface,
    required this.error,
    required this.onError,
    required this.themeMode,
    required this.shadowColor,
    this.backgroundImage,
    this.isDefault = false,
    this.textTheme,
    this.elevation,
  });

  /// 转换为 ColorScheme
  ColorScheme toColorScheme() {
    return ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      secondary: secondary,
      onSecondary: onSecondary,
      surface: surface,
      onSurface: onSurface,
      error: error,
      onError: onError,
    );
  }

  /// 转换为 ThemeData，方便直接在 MaterialApp 使用
  ThemeData toThemeData() {
    return ThemeData(
      tabBarTheme: TabBarThemeData(dividerColor: Colors.transparent),
      brightness: brightness,
      primaryColor: primary,
      colorScheme: toColorScheme(),
      scaffoldBackgroundColor: surface,
      shadowColor: shadowColor,
      textTheme:
          textTheme ??
          (brightness == Brightness.dark
              ? Typography.whiteMountainView
              : Typography.blackMountainView),
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        elevation: elevation ?? 4,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: onPrimary,
        unselectedItemColor: onSurface.withAlpha(70),
        selectedLabelStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),

        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  /// 支持 copyWith，方便修改单个属性
  AppTheme copyWith({
    String? name,
    Brightness? brightness,
    Color? primary,
    Color? onPrimary,
    Color? secondary,
    Color? onSecondary,
    Color? surface,
    Color? onSurface,
    Color? error,
    Color? onError,
    ThemeMode? themeMode,
    String? backgroundImage,
    bool? isDefault,
    Color? shadowColor,
    TextTheme? textTheme,
    double? elevation,
  }) {
    return AppTheme(
      name: name ?? this.name,
      brightness: brightness ?? this.brightness,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      secondary: secondary ?? this.secondary,
      onSecondary: onSecondary ?? this.onSecondary,
      surface: surface ?? this.surface,
      onSurface: onSurface ?? this.onSurface,
      error: error ?? this.error,
      onError: onError ?? this.onError,
      themeMode: themeMode ?? this.themeMode,
      backgroundImage: backgroundImage ?? this.backgroundImage,
      isDefault: isDefault ?? this.isDefault,
      shadowColor: shadowColor ?? this.shadowColor,
      textTheme: textTheme ?? this.textTheme,
      elevation: elevation ?? this.elevation,
    );
  }

  /// 从 JSON 构造
  factory AppTheme.fromJson(Map<String, dynamic> json) {
    Color parseColor(String hex) =>
        Color(int.parse(hex.substring(1, 7), radix: 16) + 0xFF000000);

    return AppTheme(
      name: json['name'],
      brightness: json['brightness'] == 'dark'
          ? Brightness.dark
          : Brightness.light,
      primary: parseColor(json['primary']),
      onPrimary: parseColor(json['onPrimary']),
      secondary: parseColor(json['secondary']),
      onSecondary: parseColor(json['onSecondary']),
      surface: parseColor(json['surface']),
      onSurface: parseColor(json['onSurface']),
      error: parseColor(json['error']),
      onError: parseColor(json['onError']),
      themeMode: json['themeMode'] == 'dark'
          ? ThemeMode.dark
          : json['themeMode'] == 'light'
          ? ThemeMode.light
          : ThemeMode.system,
      shadowColor: parseColor(json['shadowColor'] ?? '#000000'),
      backgroundImage: json['backgroundImage'],
      isDefault: json['isDefault'] ?? false,
      elevation: (json['elevation'] != null)
          ? double.tryParse(json['elevation'].toString())
          : null,
    );
  }
}
