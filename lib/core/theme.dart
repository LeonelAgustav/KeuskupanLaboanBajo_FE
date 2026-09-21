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

// Alias lama biar kode existing tidak error
const debitBiru = Color(0xFF2563A8);
const kreditHijau = Color(0xFF2E7D6E);

final appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: ungu,
    surface: krem,
  ),
  scaffoldBackgroundColor: krem,
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontWeight: FontWeight.w800), // nominal besar extrabold
    displayMedium: TextStyle(fontWeight: FontWeight.w800),
    displaySmall: TextStyle(fontWeight: FontWeight.w800),
    headlineLarge: TextStyle(fontWeight: FontWeight.w700), // judul halaman
    headlineMedium: TextStyle(fontWeight: FontWeight.w700),
    headlineSmall: TextStyle(fontWeight: FontWeight.w700),
    titleLarge: TextStyle(fontWeight: FontWeight.w600), // label form, status badge
    titleMedium: TextStyle(fontWeight: FontWeight.w600),
    titleSmall: TextStyle(fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(fontWeight: FontWeight.w400), // body, deskripsi
    bodyMedium: TextStyle(fontWeight: FontWeight.w400),
    bodySmall: TextStyle(fontWeight: FontWeight.w400),
    labelLarge: TextStyle(fontWeight: FontWeight.w600), // tombol aksi
    labelMedium: TextStyle(fontWeight: FontWeight.w600),
    labelSmall: TextStyle(fontWeight: FontWeight.w500),
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
);
