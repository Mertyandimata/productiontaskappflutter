import 'package:flutter/material.dart';


class AppColors {
  // CMYK: 80 - 0 - 100 - 75 (Koyu Yeşil)
  static const Color darkGreen = Color(0xFF0A3409);
  
  // CMYK: 65 - 34 - 61 - 21 (Orta Yeşil)
  static const Color mediumGreen = Color(0xFF4A644F);
  
  // CMYK: 44 - 20 - 42 - 4 (Açık Yeşil)
  static const Color lightGreen = Color(0xFF8BA68F);
  
  // CMYK: 27 - 12 - 23 - 0 (Çok Açık Yeşil)
  static const Color veryLightGreen = Color(0xFFBACBBC);
  
  // CMYK: 6 - 3 - 5 - 0 (En Açık Yeşil / Neredeyse Beyaz)
  static const Color almostWhite = Color(0xFFF0F2F1);

  // Uygulamanın ana rengi olarak koyu yeşili kullanabiliriz
  static const Color primary = darkGreen;
  
  // Diğer renk tanımlamaları
  static const Color secondary = mediumGreen;
  static const Color backgroundLight = almostWhite;
  static const Color backgroundDark = veryLightGreen;
  static const Color textDark = darkGreen;
  static const Color textLight = almostWhite;
}