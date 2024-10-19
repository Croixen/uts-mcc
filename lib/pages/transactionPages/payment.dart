import 'package:app_penjualan_elektronik/definitions/cartModel.dart';
import 'package:app_penjualan_elektronik/definitions/users.dart';
import 'package:app_penjualan_elektronik/providers/cart_provider.dart';
import 'package:app_penjualan_elektronik/providers/user_provider.dart';
import 'package:app_penjualan_elektronik/utils/fontsFactory.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Payment extends StatefulWidget {
  final int sum;
  const Payment({super.key, required this.sum});
  @override
  State<StatefulWidget> createState() => _Payment();
}

class _Payment extends State<Payment> {
  List<CartModel> cartLoad = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void handleTransaction() async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return SimpleDialog(
            backgroundColor: Colors.black54.withOpacity(0.1),
            children: const [
              Center(
                child: CircularProgressIndicator(),
              )
            ],
          );
        });
    try {
      final UserCreds user =
          Provider.of<Userproviders>(context, listen: false).user;
      print(user.alamat);
      final response = await Supabase.instance.client
          .from('transactions')
          .insert({
            'total': widget.sum,
            'userId': user.uuid,
            'alamat': user.alamat!
          })
          .select('transactionId')
          .single();

      if (response.isEmpty) {
        if (mounted) {
          Navigator.pop(context);
        }
        throw Exception('Gagal Mengiirm Data');
      } else {
        for (CartModel index in cartLoad) {
          final int updatedAmount = index.products['quantity'] - index.amount;
          await Supabase.instance.client
              .from('products')
              .update({'quantity': updatedAmount}).eq(
                  'productId', index.products['productId']);
          if (mounted) {
            await Supabase.instance.client.from('sales').insert({
              'productId': index.products['productId'],
              'uuid':
                  Provider.of<Userproviders>(context, listen: false).user.uuid,
              'transactionId': response['transactionId'],
              'amount': index.amount
            });
          }

          await Supabase.instance.client
              .from('cart')
              .delete()
              .eq('userId', user.uuid!);
        }

        if (mounted) {
          Navigator.pop(context);
          showDialog(
              context: context,
              builder: (context) {
                return SingleChildScrollView(
                  child: AlertDialog(
                    title: const Text('Pemberitahuan'),
                    content: const Text('Transaksi Berhasil Dilakukan!'),
                    actions: [
                      TextButton(
                          onPressed: () {
                            context.read<CartProvider>().clearCartSum();
                            Navigator.popUntil(
                                context, ModalRoute.withName('home'));
                          },
                          child: const Text('Tutup'))
                    ],
                  ),
                );
              });
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Peringatan'),
                content: SingleChildScrollView(
                  child: Text(
                      'Terjadi Kesalahan Ketika Hendak Mengirim Data, error: $e'),
                ),
                actions: [
                  TextButton(
                      onPressed: () {
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
  void initState() {
    super.initState();
    initProvider();
  }

  void initProvider() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        cartLoad = context.read<CartProvider>().cartItem;
      });
    });
  }

  @override
  Widget build(BuildContext build) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Payment',
          style: googleFont(fontsize: 24, fontweight: FontWeight.bold),
        ),
        titleSpacing: 5,
      ),
      body: Column(
        children: [
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  builder: (context) {
                    return Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: SingleChildScrollView(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(5, 20, 5, 5),
                          height: 300,
                          decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12))),
                          child: Column(
                            children: [
                              const Center(
                                child: Text(
                                  'Isi Kredensial Kartu!',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20.0),
                                child: Divider(
                                  color: Colors.black,
                                  thickness: 2,
                                ),
                              ),
                              Flexible(
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.45,
                                              child: TextFormField(
                                                textAlign: TextAlign.center,
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Tidak Boleh Kosong';
                                                  }
                                                  if (value.length != 3) {
                                                    return 'CVV Tidak Valid';
                                                  }
                                                  return null;
                                                },
                                                decoration:
                                                    const InputDecoration(
                                                  labelStyle:
                                                      TextStyle(fontSize: 16),
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  120))),
                                                  constraints: BoxConstraints(
                                                      maxHeight: 70),
                                                  hintText: "CVV",
                                                ),
                                              )),
                                          SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.45,
                                              child: TextFormField(
                                                textAlign: TextAlign.center,
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Tidak Boleh Kosong';
                                                  }
                                                  return null;
                                                },
                                                decoration:
                                                    const InputDecoration(
                                                  labelStyle:
                                                      TextStyle(fontSize: 16),
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  120))),
                                                  constraints: BoxConstraints(
                                                      maxHeight: 70),
                                                  hintText: "Nomor kartu",
                                                ),
                                              ))
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.70,
                                          child: TextFormField(
                                            textAlign: TextAlign.center,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Tidak Boleh Kosong';
                                              }
                                              return null;
                                            },
                                            decoration: const InputDecoration(
                                              labelStyle:
                                                  TextStyle(fontSize: 16),
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              120))),
                                              constraints:
                                                  BoxConstraints(maxHeight: 70),
                                              hintText: "Nama",
                                            ),
                                          )),
                                      const Spacer(),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 0, 0, 10),
                                        child: ElevatedButton(
                                            style: const ButtonStyle(
                                                elevation:
                                                    WidgetStatePropertyAll(10),
                                                backgroundColor:
                                                    WidgetStatePropertyAll(
                                                        Colors.green),
                                                fixedSize:
                                                    WidgetStatePropertyAll(
                                                        Size(250, 50))),
                                            onPressed: () {
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                handleTransaction();
                                              }
                                            },
                                            child: const Text(
                                              'Konfirmasi',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            )),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  });
            },
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 10, 20, 5),
              height: 60,
              child: const Card(
                elevation: 3,
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(Icons.credit_card),
                      VerticalDivider(
                        thickness: 1,
                      ),
                      Text('Via Bank')
                    ],
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Container(
                      padding: const EdgeInsets.fromLTRB(5, 20, 5, 5),
                      height: 600,
                      child: Column(
                        children: [
                          const Center(
                            child: Text(
                              'Scan QR Code!',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            child: Divider(
                              color: Colors.black,
                              thickness: 2,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            height: 180,
                            child: Image.network(
                                'https://www.dummies.com/wp-content/uploads/324172.image0.jpg'),
                          ),
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                            child: ElevatedButton(
                                style: const ButtonStyle(
                                    elevation: WidgetStatePropertyAll(10),
                                    backgroundColor:
                                        WidgetStatePropertyAll(Colors.green),
                                    fixedSize:
                                        WidgetStatePropertyAll(Size(250, 50))),
                                onPressed: () {
                                  handleTransaction();
                                },
                                child: const Text(
                                  'Konfirmasi',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )),
                          )
                        ],
                      ),
                    );
                  });
            },
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 5, 20, 20),
              height: 60,
              child: const Card(
                elevation: 3,
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(Icons.qr_code_2_outlined),
                      VerticalDivider(
                        thickness: 1,
                      ),
                      Text('Via QRIS')
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
