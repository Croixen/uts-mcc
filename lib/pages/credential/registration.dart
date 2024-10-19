import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:app_penjualan_elektronik/definitions/users.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  State<Registration> createState() {
    return _Registration();
  }
}

class _Registration extends State<Registration> {
  final userInstance = Supabase.instance.client.from('users');
  final storageInstance = Supabase.instance.client.storage.from('images');
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  //State
  UserCreds user = UserCreds(email: '', password: '', username: '');
  bool _showPassword = false;

  TextEditingController usernameController = TextEditingController();

  void _togglevisibility() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  void _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        user.foto = File(pickedFile.path);
      });
    } else {
      _showAlertDialog('Error', 'Tidak ada gambar yang dipilih.');
    }
  }

  void handleRegister() async {
    try {
      if (user.foto == null) {
        _showAlertDialog('Error', 'Foto Profil Tidak Boleh Kosong');
        return;
      }
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
      final validating = await userInstance
          .select('uuid')
          .eq('email', user.email)
          .maybeSingle();

      if (validating != null) {
        throw Exception('Email Telah Digunakan');
      } else {
        String ext = path.extension(user.foto!.path);
        final String fullPath = await storageInstance.upload(
          'foto_profil/${DateTime.now().toString()}.$ext',
          user.foto!,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );

        user.urlFoto =
            'https://iqgrsjddtctvxxqkoxro.supabase.co/storage/v1/object/public/$fullPath';

        final response = await userInstance
            .insert(user.toMap())
            .select('uuid')
            .maybeSingle();

        if (response != null && response.isNotEmpty) {
          pop();
          pop();
        } else {
          _showAlertDialog(
              'Alert!', 'Terdapat kesalahan di password atau email');
        }
      }
    } catch (e) {
      pop();
      _showAlertDialog('Error', e.toString());
    }
  }

  void pop() {
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _showAlertDialog(String title, String message) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: <Widget>[
              TextButton(
                onPressed: () => pop(),
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
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
                  'Registrasi',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                ),
                const Text('Inputkan Data Registrasi Anda Disini!'),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: user.foto != null
                                  ? FileImage(user.foto!)
                                  : null,
                              child: user.foto == null
                                  ? const Icon(Icons.person, size: 50)
                                  : null, // Tampilkan icon person jika belum ada foto
                            ),
                            const Positioned(
                                right: -2,
                                bottom: 0,
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(300)),
                                  child: Badge(
                                    backgroundColor: Colors.white,
                                    label: Icon(Icons.image_outlined),
                                  ),
                                ))
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: (MediaQuery.of(context).size.width * 0.75),
                        child: TextFormField(
                          onSaved: (value) {
                            user.email = value!;
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
                          controller: usernameController,
                          onSaved: (value) {
                            user.username = value!;
                          },
                          decoration: const InputDecoration(
                              label: Text('Username'),
                              icon: Icon(Icons.person_2_outlined)),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Username Tidak Boleh Kosong!";
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        width: (MediaQuery.of(context).size.width * 0.75),
                        child: TextFormField(
                          obscureText: !_showPassword,
                          style: const TextStyle(color: Colors.black),
                          onSaved: (value) {
                            user.password = value!;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Password Tidak Boleh Kosong!";
                            }
                            if (value.length < 8) {
                              return 'Password Tidak Bisa Kurang Dari 8 Huruf';
                            } else if (value.length > 16) {
                              return 'Password Tidak Bisa Lebih Dari 16 Baris';
                            }
                            return null;
                          },
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
                  height: 20,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        style: ButtonStyle(
                            foregroundColor:
                                const WidgetStatePropertyAll(Colors.white),
                            backgroundColor:
                                WidgetStateProperty.all(Colors.green)),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final fieldValue = _formKey.currentState!;
                            fieldValue.save();
                            handleRegister();
                          }
                        },
                        child: const Text('Registrasi')),
                    const SizedBox(
                      height: 20,
                      width: 20,
                    ),
                    ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(Colors.red),
                        ),
                        onPressed: () {
                          pop();
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.white),
                        ))
                  ],
                )
              ],
            )),
      ),
    ));
  }
}
