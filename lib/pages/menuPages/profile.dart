// ignore_for_file: use_build_context_synchronously

import 'package:app_penjualan_elektronik/definitions/users.dart';
import 'package:app_penjualan_elektronik/pages/credential/login.dart';
import 'package:app_penjualan_elektronik/providers/user_provider.dart';
import 'package:app_penjualan_elektronik/utils/fontsFactory.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});
  @override
  State<Profile> createState() {
    return _Profile();
  }
}

class _Profile extends State<Profile> {
  static GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    UserCreds user = Provider.of<Userproviders>(context).user;
    return SizedBox(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 80, 40, 20),
            child: Center(
              child: SizedBox(
                height: 130,
                width: 130,
                child: CircleAvatar(
                  radius: 100,
                  backgroundImage: NetworkImage(user.urlFoto != null
                      ? user.urlFoto!
                      : 'https://media.istockphoto.com/id/1166126620/vector/person-gray-photo-placeholder-woman.jpg?s=612x612&w=0&k=20&c=HG8k9ulU4SVdiZ14pvLc3uPnh_UgrLq_tR7VBAXFKaA='),
                ),
                // '
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 30, 0, 0),
              padding: const EdgeInsets.all(5),
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black,
                        offset: Offset(0, -1),
                        blurStyle: BlurStyle.outer,
                        blurRadius: 2,
                        spreadRadius: 0.9)
                  ]),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 5,
                      ),
                      const Text(
                        'Biodata',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 32,
                            fontWeight: FontWeight.bold),
                      ),
                      const Divider(),
                      Text(
                        user.username,
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '(${user.uuid!})',
                        style: const TextStyle(
                            color: Color.fromARGB(255, 151, 151, 151),
                            fontSize: 12),
                      ),
                      Text(
                        user.email,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 18),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Stack(children: [
                        Center(
                          child: Container(
                            margin: const EdgeInsets.all(5),
                            padding: const EdgeInsets.all(20),
                            height: 190,
                            width: MediaQuery.of(context).size.width * 0.8,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1, color: Colors.black)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Text(
                                  'Alamat',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  user.alamat == null || user.alamat == ''
                                      ? 'Kosong'
                                      : user.alamat!,
                                  style: TextStyle(
                                      color: user.alamat == null
                                          ? const Color.fromARGB(
                                              255, 150, 150, 150)
                                          : Colors.black,
                                      fontSize: 14),
                                )
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                            top: 8,
                            right: 25,
                            child: Container(
                              height: 30,
                              width: 30,
                              decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(360)),
                                  color: Color.fromARGB(97, 71, 71, 71)),
                              child: IconButton(
                                  padding:
                                      EdgeInsets.zero, // Remove default padding
                                  constraints: const BoxConstraints(
                                      maxHeight: 10,
                                      maxWidth:
                                          10), // Remove constraints to customize size
                                  onPressed: () {
                                    showModalBottomSheet(
                                      isScrollControlled: true,
                                      context: context,
                                      builder: (context) {
                                        final userInstance = Supabase
                                            .instance.client
                                            .from('users');
                                        String alamat = '';
                                        handleAlamatUpdate() async {
                                          try {
                                            if (mounted) {
                                              showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder: (context) {
                                                  return const Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: Colors.white,
                                                    ),
                                                  );
                                                },
                                              );
                                            }

                                            final response = await userInstance
                                                .update({'alamat': alamat})
                                                .eq(
                                                    'uuid',
                                                    Provider.of<Userproviders>(
                                                            context,
                                                            listen: false)
                                                        .user
                                                        .uuid!)
                                                .select(
                                                    'uuid, email, username, image_url, alamat')
                                                .maybeSingle();
                                            if (response != null &&
                                                response.isNotEmpty) {
                                              if (mounted) {
                                                Navigator.pop(context);
                                                context
                                                    .read<Userproviders>()
                                                    .setUser(
                                                        response['uuid'],
                                                        response['email'],
                                                        response['username'],
                                                        response['image_url'],
                                                        response['alamat']);
                                                Navigator.pop(context);
                                              }
                                            } else {
                                              if (mounted) {
                                                Navigator.pop(context);
                                                showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        title: const Text(
                                                            'Alert!'),
                                                        content: const Text(
                                                            'Terdapat Kesalahan Di Password atau Email'),
                                                        actions: <Widget>[
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    context),
                                                            child: const Text(
                                                                'Close'),
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
                                                      title: const Text(
                                                          'Terjadi Kesalahan, bukan anda tapi dari kami!'),
                                                      content:
                                                          SingleChildScrollView(
                                                              child: Text(
                                                                  'Terjadi Kesalahan, nih, penjelasan : $e')),
                                                      actions: <Widget>[
                                                        TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);

                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: const Text(
                                                                'Tutup'))
                                                      ],
                                                    );
                                                  });
                                            }
                                          }
                                        }

                                        return Form(
                                          key: _formKey,
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                              bottom: MediaQuery.of(context)
                                                  .viewInsets
                                                  .bottom, // Adjust for keyboard
                                            ),
                                            child: SingleChildScrollView(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                height: 300,
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      'Isi Alamat',
                                                      style: googleFont(
                                                        fontsize: 24,
                                                        colour: Colors.black87,
                                                        fontweight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const Divider(),
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    TextFormField(
                                                      style: googleFont(
                                                          fontsize: 14),
                                                      onSaved: (newValue) {
                                                        setState(
                                                          () {
                                                            alamat = newValue!;
                                                          },
                                                        );
                                                      },
                                                      maxLength: 120,
                                                      maxLines: 5,
                                                      validator: (value) {
                                                        if (value == null ||
                                                            value.isEmpty) {
                                                          return 'Form Tidak Boleh Kosong';
                                                        }
                                                        if (value.length >
                                                            120) {
                                                          return 'Tidak boleh melebihi 120 karakter';
                                                        }
                                                        return null;
                                                      },
                                                      decoration: const InputDecoration(
                                                          border:
                                                              OutlineInputBorder(),
                                                          hintText:
                                                              'Inputkan Alamat, Nomor Telepon, Serta Keterangan dan Penerima',
                                                          hintStyle: TextStyle(
                                                              fontSize: 14),
                                                          labelStyle: TextStyle(
                                                              fontSize: 14)),
                                                    ),
                                                    const Spacer(),
                                                    ElevatedButton(
                                                        onPressed: () {
                                                          if (_formKey
                                                              .currentState!
                                                              .validate()) {
                                                            _formKey
                                                                .currentState!
                                                                .save();
                                                            handleAlamatUpdate();
                                                          }
                                                        },
                                                        style: const ButtonStyle(
                                                            fixedSize:
                                                                WidgetStatePropertyAll(
                                                                    Size.fromWidth(
                                                                        200)),
                                                            elevation:
                                                                WidgetStatePropertyAll(
                                                                    3),
                                                            shape: WidgetStatePropertyAll(
                                                                RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(5))))),
                                                        child: const Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Icon(
                                                                Icons.download),
                                                            Text('Simpan'),
                                                          ],
                                                        ))
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  icon: const Icon(Icons.edit_outlined)),
                            ))
                      ]),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: Center(
                          child: ElevatedButton(
                              style: const ButtonStyle(
                                  elevation: WidgetStatePropertyAll(12),
                                  backgroundColor: WidgetStatePropertyAll(
                                      Color.fromARGB(255, 255, 255, 255))),
                              onPressed: () async {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();

                                prefs.remove('uuid');

                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginScreen(),
                                    ));
                              },
                              child: Row(
                                children: [
                                  const Icon(Icons.logout_outlined),
                                  Text(
                                    'Log Out',
                                    style: googleFont(
                                      colour: Colors.red,
                                    ),
                                  ),
                                ],
                              )),
                        ),
                      )
                    ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
