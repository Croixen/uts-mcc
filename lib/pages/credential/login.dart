import 'package:app_penjualan_elektronik/pages/credential/registration.dart';
import 'package:app_penjualan_elektronik/pages/menuPages/menu.dart';
import 'package:app_penjualan_elektronik/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LoginScreen();
  }
}

class _LoginScreen extends State<LoginScreen> {
  final userInstance = Supabase.instance.client.from('users');

  final _formKey = GlobalKey<FormState>();

  //State
  String email = '';
  String password = '';
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
  }

  void setProvider(final response) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<Userproviders>().setUser(response['uuid'], response['email'],
          response['username'], response['image_url'], response['alamat']);
      Navigator.of(context).push(_createRoute());
    });
  }

  void _togglevisibility() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  void handleLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          },
        );
      }

      final response = await userInstance
          .select('uuid, email, username, image_url, alamat')
          .eq('email', email.toLowerCase())
          .eq('password', password)
          .maybeSingle();

      if (response != null && response.isNotEmpty) {
        if (mounted) {
          Navigator.pop(context);
          prefs.setString('uuid', response['uuid']);
          setProvider(response);
        }
      } else {
        if (mounted) {
          Navigator.pop(context);
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Alert!'),
                  content:
                      const Text('Terdapat Kesalahan Di Password atau Email'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    )
                  ],
                );
              });
        }
      }
    } catch (e) {
      if (mounted) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title:
                    const Text('Terjadi Kesalahan, bukan anda tapi dari kami!'),
                content: SingleChildScrollView(
                    child: Text('Terjadi Kesalahan, nih, penjelasan : $e')),
                actions: <Widget>[
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text('Tutup'))
                ],
              );
            });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
      body: Form(
        key: _formKey,
        child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Log In',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                ),
                const Text('Silahkan Login Untuk Menggunakan Aplikasi Kami!'),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  child: Column(
                    children: [
                      SizedBox(
                        width: (MediaQuery.of(context).size.width * 0.75),
                        child: TextFormField(
                          onSaved: (value) {
                            email = value!;
                          },
                          decoration: const InputDecoration(
                              label: Text('Email'), icon: Icon(Icons.email)),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Email Tidak Boleh Kosong!";
                            } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                .hasMatch(value)) {
                              return "Masukkan Email yang Valid!";
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        width: (MediaQuery.of(context).size.width * 0.75),
                        child: TextFormField(
                          onSaved: (value) {
                            password = value!;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Password Tidak Boleh Kosong!";
                            }
                            return null;
                          },
                          obscureText: !_showPassword,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            label: const Text('Password'),
                            icon: const Icon(Icons.key_rounded),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                _togglevisibility();
                              },
                              child: Icon(
                                _showPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(Colors.blue),
                        foregroundColor: WidgetStateProperty.all(Colors.white)),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final formState = _formKey.currentState!;
                        formState.save();
                        handleLogin();
                      }
                    },
                    child: const Text('Log In!')),
                const SizedBox(
                  height: 20,
                ),
                TextButton(
                    onPressed: () {
                      if (mounted) {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const Registration(),
                        ));
                      }
                    },
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.app_registration_outlined),
                        SizedBox(
                          width: 8,
                        ),
                        Flexible(
                          child: Text(
                            'Masih Belum Bergabung Dengan Kami? Ayo Gabung!',
                            softWrap: true,
                            overflow: TextOverflow.fade,
                          ),
                        )
                      ],
                    ))
              ],
            )),
      ),
    ));
  }
}

Route _createRoute() {
  return PageRouteBuilder(
    settings: const RouteSettings(name: 'home'),
    pageBuilder: (context, animation, secondaryAnimation) => const MainMenu(),
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
