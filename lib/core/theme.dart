import 'package:flutter/material.dart';

// Palet liturgis Keuskupan Labuan Bajo (UI_DESIGN.md §1.1)
const krem = Color(0xFFFAF6F0); // background hangat kertas
const ungu = Color(0xFF5B2E7C); // ungu rohani, warna utama
const emas = Color(0xFFC9A227); // aksen premium (ikon/border saja)
const emasTeks = Color(0xFF8A6D1D); // ponytail: #C9A227 di krem kontras rendah (~2.5:1), ini untuk teks nominal
const hijauPendapatan = Color(0xFF2E7D6E);
const merahPengeluaran = Color(0xFFC96F2E);
const orangeKhas = Color(0xFFC96F2E); // peringatan / pending (sama dengan merahPengeluaran)
const darkText = Color(0xFF3A2E2E);
const abuHangat = Color(0xFF8A7F7A);

// Modern semantic colors (design system)
const primaryGreen = Color(0xFF16A34A);
const successGreen = Color(0xFF22C55E);
const dangerRed = Color(0xFFEF4444);
const warningOrange = Color(0xFFF59E0B);
const infoBlue = Color(0xFF3B82F6);
const surfaceWhite = Color(0xFFFFFFFF);
const backgroundLight = Color(0xFFF8FAFC);
const textDark = Color(0xFF0F172A);
const textSecondary = Color(0xFF475569);
const textMuted2 = Color(0xFF94A3B8);

// Alias lama biar kode existing tidak error
const debitBiru = Color(0xFF2563A8);
const kreditHijau = Color(0xFF2E7D6E);

final appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: ungu,
    surface: krem,
    primary: ungu,
  ),
  scaffoldBackgroundColor: krem,
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontWeight: FontWeight.w800, fontSize: 32, letterSpacing: -0.02), // nominal besar extrabold
    displayMedium: TextStyle(fontWeight: FontWeight.w800, fontSize: 28),
    displaySmall: TextStyle(fontWeight: FontWeight.w800, fontSize: 24),
    headlineLarge: TextStyle(fontWeight: FontWeight.w700, fontSize: 24), // judul halaman
    headlineMedium: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
    headlineSmall: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
    titleLarge: TextStyle(fontWeight: FontWeight.w600, fontSize: 16), // label form, status badge
    titleMedium: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
    titleSmall: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
    bodyLarge: TextStyle(fontWeight: FontWeight.w400, fontSize: 16), // body, deskripsi
    bodyMedium: TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
    bodySmall: TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
    labelLarge: TextStyle(fontWeight: FontWeight.w600, fontSize: 14), // tombol aksi
    labelMedium: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
    labelSmall: TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: ungu,
    foregroundColor: Colors.white,
    // aksen "menyeberang" tipis emas pada AppBar
    shape: Border(bottom: BorderSide(color: emas, width: 2)),
    titleTextStyle: TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 20,
      color: Colors.white,
    ),
  ),
  cardTheme: CardThemeData(
    elevation: 1,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    color: surfaceWhite,
  ),
  // TabBar di atas AppBar ungu → label terang, indikator emas tebal
  tabBarTheme: TabBarThemeData(
    labelColor: Colors.white,
    unselectedLabelColor: Colors.white70,
    indicatorColor: emas,
    indicatorSize: TabBarIndicatorSize.label,
    indicator: const BoxDecoration(
      border: Border(bottom: BorderSide(color: emas, width: 3)),
    ),
    labelStyle: const TextStyle(fontWeight: FontWeight.w600),
    unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
    dividerColor: Colors.transparent,
  ),
  navigationBarTheme: const NavigationBarThemeData(
    backgroundColor: krem,
    labelTextStyle: WidgetStatePropertyAll(
      TextStyle(fontWeight: FontWeight.w500),
    ),
  ),
  navigationRailTheme: const NavigationRailThemeData(
    backgroundColor: krem,
    labelType: NavigationRailLabelType.all,
    selectedLabelTextStyle: TextStyle(fontWeight: FontWeight.w600),
    unselectedLabelTextStyle: TextStyle(fontWeight: FontWeight.normal),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    filled: true,
    fillColor: surfaceWhite,
  ),
);

