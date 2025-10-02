import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/bible_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BibleProvider(),
      child: Consumer<BibleProvider>(
        builder: (context, provider, child) {
          return MaterialApp(
            title: 'Bible App',
            theme: provider.darkMode
                ? ThemeData.dark().copyWith(
                    primaryColor: Colors.blue,
                    colorScheme: ColorScheme.dark().copyWith(
                      primary: Colors.blue,
                    ),
                  )
                : ThemeData(
                    primarySwatch: Colors.blue,
                    visualDensity: VisualDensity.adaptivePlatformDensity,
                  ),
            home: HomeScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
