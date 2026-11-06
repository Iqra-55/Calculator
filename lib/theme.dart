import 'package:flutter/material.dart';
class Apptheme{
 static ThemeData get lightTheme{
return ThemeData(
  brightness:Brightness.light,
  scaffoldBackgroundColor: const Color(0xFFF4F6F9),
  cardColor:const Color.fromARGB(235, 240, 238, 238),
);
  }
  static ThemeData get darkTheme{
    return ThemeData(
brightness:Brightness.dark,
 scaffoldBackgroundColor: const Color(0xFF141416),
 cardColor:const Color(0xFF1D1D22),
    );
  }
}