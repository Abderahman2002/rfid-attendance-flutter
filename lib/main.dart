import 'package:flutter/material.dart';

import 'screens/startup_page.dart';

void main() {

  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {

  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner: false,

      title: "RFID Attendance System",

      // =====================================
      // THEME
      // =====================================

      theme: ThemeData(

        useMaterial3: true,

        scaffoldBackgroundColor:
            const Color(0xFFF5F7FB),

        primaryColor:
            const Color(0xFF1565C0),

        colorScheme:
            ColorScheme.fromSeed(

          seedColor:
              const Color(0xFF1565C0),
        ),

        // =====================================
        // APP BAR
        // =====================================

        appBarTheme:
            const AppBarTheme(

          elevation: 0,

          centerTitle: false,

          backgroundColor:
              Color(0xFFF5F7FB),

          foregroundColor:
              Color(0xFF111827),

          titleTextStyle:
              TextStyle(

            fontSize: 22,

            fontWeight:
                FontWeight.bold,

            color:
                Color(0xFF111827),
          ),
        ),

        // =====================================
        // CARD THEME
        // =====================================

        cardTheme:
            CardThemeData(

          elevation: 0,

          color: Colors.white,

          shape:
              RoundedRectangleBorder(

            borderRadius:
                BorderRadius.circular(
              24,
            ),
          ),
        ),

        // =====================================
        // BUTTON THEME
        // =====================================

        elevatedButtonTheme:
            ElevatedButtonThemeData(

          style:
              ElevatedButton.styleFrom(

            elevation: 0,

            minimumSize:
                const Size(
              double.infinity,
              56,
            ),

            backgroundColor:
                const Color(
              0xFF1565C0,
            ),

            foregroundColor:
                Colors.white,

            shape:
                RoundedRectangleBorder(

              borderRadius:
                  BorderRadius.circular(
                18,
              ),
            ),
          ),
        ),

        // =====================================
        // INPUT THEME
        // =====================================

        inputDecorationTheme:
            InputDecorationTheme(

          filled: true,

          fillColor: Colors.white,

          contentPadding:
              const EdgeInsets.symmetric(

            horizontal: 18,

            vertical: 18,
          ),

          border:
              OutlineInputBorder(

            borderRadius:
                BorderRadius.circular(
              18,
            ),

            borderSide:
                BorderSide.none,
          ),

          enabledBorder:
              OutlineInputBorder(

            borderRadius:
                BorderRadius.circular(
              18,
            ),

            borderSide:
                BorderSide.none,
          ),

          focusedBorder:
              OutlineInputBorder(

            borderRadius:
                BorderRadius.circular(
              18,
            ),

            borderSide:
                const BorderSide(

              color:
                  Color(0xFF1565C0),

              width: 1.5,
            ),
          ),
        ),

        // =====================================
        // SNACKBAR THEME
        // =====================================

        snackBarTheme:
            SnackBarThemeData(

          behavior:
              SnackBarBehavior.floating,

          shape:
              RoundedRectangleBorder(

            borderRadius:
                BorderRadius.circular(
              16,
            ),
          ),
        ),
      ),

      // =====================================
      // STARTUP PAGE
      // =====================================

      home: const StartupPage(),
    );
  }
}