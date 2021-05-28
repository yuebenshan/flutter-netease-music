part of 'settings.dart';

//网易红调色板
const _swatchNeteaseRed = const MaterialColor(0xFFFF6800, {
  900: const Color(0xffff6800),
  800: const Color(0xffbe652a),
  700: const Color(0xffcb6f31),
  600: const Color(0xffdd7137),
  500: const Color(0xffec8038),
  400: const Color(0xffe88151),
  300: const Color(0xffdf9674),
  200: const Color(0xffeab39a),
  100: const Color(0xfffce0ce),
  50: const Color(0xfffef2eb),
});

//app主题
final quietThemes = [
  _buildTheme(_swatchNeteaseRed),
  _buildTheme(Colors.blue),
  _buildTheme(Colors.green),
  _buildTheme(Colors.amber),
  _buildTheme(Colors.teal),
];

final quietDarkTheme = ThemeData.dark().copyWith(
  backgroundColor: Colors.white12,
);

ThemeData _buildTheme(Color primaryColor) {
  return ThemeData(
      primaryColor: primaryColor,
      dividerColor: Color(0xfff5f5f5),
      iconTheme: IconThemeData(color: Color(0xFFb3b3b3)),
      primaryColorLight: primaryColor,
      backgroundColor: Colors.white);
}
