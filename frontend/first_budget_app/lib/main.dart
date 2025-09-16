import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '가계부 앱',
      darkTheme: ThemeData(
        brightness: Brightness.dark, // 이걸 설정하면 글자색 등이 자동으로 반전됩니다.
        scaffoldBackgroundColor: const Color(0xFF1C1C1E), // 애플 다크모드 배경색
        primaryColor: Colors.amber, // 주황색 계열을 포인트 색상으로
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.amber, // + 버튼 색상
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Colors.amber, // 하단 탭 선택된 아이콘 색상
        ),
        cardColor: const Color(0xFF2C2C2E), // 카드 배경색
      ),

      // 🌙 앱을 항상 다크 모드로 실행
      themeMode: ThemeMode.dark,
      home: HomeScreen(),
    );
  }
}
