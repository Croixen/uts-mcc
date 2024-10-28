import 'package:app_penjualan_elektronik/pages/credential/login.dart';
import 'package:app_penjualan_elektronik/pages/menuPages/menu.dart';
import 'package:app_penjualan_elektronik/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final userInstance = Supabase.instance.client.from('users');
  @override
  void initState() {
    super.initState();
    _checkUUID();
  }

  void setProvider(final response) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<Userproviders>().setUser(response['uuid'], response['email'],
          response['username'], response['image_url'], response['alamat']);
    });
  }

  Future<void> _checkUUID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uuid = prefs.getString('uuid');

    if (uuid == null || uuid.isEmpty) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          _createRoute(const LoginScreen()),
        );
      }
    } else {
      try {
        final response = await userInstance
            .select('uuid, email, username, image_url, alamat')
            .eq('uuid', uuid)
            .maybeSingle();

        if (response != null && response.isNotEmpty) {
          if (mounted) {
            setProvider(response);
            if (mounted) {
              Navigator.pushReplacement(
                context,
                _createRoute(const MainMenu()),
              );
            }
          }
        } else {
          if (mounted) {
            showDialog(
                context: context,
                builder: (context) {
                  return const AlertDialog(
                      title: Text('Alert!'), content: Text('Ada Kesalahan'));
                });
          }
        }
      } catch (e) {
        if (mounted) {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text(
                      'Terjadi Kesalahan, bukan anda tapi dari kami!'),
                  content: SingleChildScrollView(
                      child: Text('Terjadi Kesalahan, nih, penjelasan : $e')),
                );
              });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: Image.asset('assets/splash.png')),
    );
  }
}

Route _createRoute(Widget nextRoute) {
  return PageRouteBuilder(
    settings: const RouteSettings(name: 'home'),
    pageBuilder: (context, animation, secondaryAnimation) => nextRoute,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
