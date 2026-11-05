
import 'package:flutter/material.dart';

import 'features/videos/presentation/video_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF155F8E);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Streamly',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
        ),
      ),
      home: const VideoListScreen(),
    );
  }
}
