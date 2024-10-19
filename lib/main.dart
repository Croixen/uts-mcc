import 'package:app_penjualan_elektronik/providers/cart_provider.dart';
import 'package:app_penjualan_elektronik/providers/user_provider.dart';
import 'package:app_penjualan_elektronik/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:env_flutter/env_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();

  await Supabase.initialize(
    url: dotenv.env['SUPA_URL']!,
    anonKey: dotenv.env['SUPA_ANON_KEY']!,
  );
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<Userproviders>(create: (_) => Userproviders()),
      ChangeNotifierProvider<CartProvider>(create: (_) => CartProvider())
    ],
    child: SafeArea(
        child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          textTheme: GoogleFonts.interTextTheme(),
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 33, 5, 156))),
      home: const SplashScreen(),
    )),
  ));
}
