import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'home_page.dart';


void main() => runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      initialRoute: '/',
      home: HomePage(),
    )
);
