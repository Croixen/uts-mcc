import 'package:app_penjualan_elektronik/definitions/products.dart';
import 'package:app_penjualan_elektronik/definitions/users.dart';
import 'package:app_penjualan_elektronik/pages/productsPage/product_detail.dart';
import 'package:app_penjualan_elektronik/providers/user_provider.dart';
import 'package:app_penjualan_elektronik/utils/fontsFactory.dart';
import 'package:app_penjualan_elektronik/utils/formatter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toastification/toastification.dart';

class Katalog extends StatefulWidget {
  final String kategori;
  const Katalog({super.key, required this.kategori});

  @override
  State<Katalog> createState() => _Katalog();
}

class _Katalog extends State<Katalog> {
  String uuid = '';
  var productsInstance;
  final cartInstance = Supabase.instance.client.from('cart');
  UserCreds user = UserCreds(email: '', username: '');
  @override
  void initState() {
    super.initState();
    setState(() {
      productsInstance = Supabase.instance.client
          .from('products')
          .select('*, categories!inner(category)')
          .eq('categories.category', widget.kategori);
      user = Provider.of<Userproviders>(context, listen: false).user;
    });
  }

  void handleCart(Map<String, dynamic> product) async {
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
      if (mounted) {
        final validation = await cartInstance
            .select('cartId, amount')
            .eq('userId', user.uuid!)
            .eq('productId', product['productId'])
            .maybeSingle();

        if (validation != null) {
          int prevAmount = validation['amount'];
          if (prevAmount + 1 < product['quantity']) {
            await cartInstance
                .update({'amount': prevAmount + 1})
                .eq('cartId', validation['cartId'])
                .whenComplete(() {
                  if (mounted) {
                    toastification.show(
                      context: context,
                      type: ToastificationType.success,
                      style: ToastificationStyle.flat,
                      autoCloseDuration: const Duration(seconds: 2),
                      title:
                          const Text('Item Telah Ditambahkan Ke Keranjang 👍'),
                      icon: const Icon(Icons.check),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x07000000),
                          blurRadius: 16,
                          offset: Offset(0, 16),
                          spreadRadius: 0,
                        )
                      ],
                      primaryColor: Colors.white,
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      showProgressBar: false,
                    );
                  }
                });
          } else {
            if (mounted) {
              toastification.show(
                context: context,
                type: ToastificationType.info,
                style: ToastificationStyle.flat,
                autoCloseDuration: const Duration(seconds: 2),
                title: const Text('Item Melebihi Quantity Gudang'),
                icon: const Icon(Icons.sms_failed),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x07000000),
                    blurRadius: 16,
                    offset: Offset(0, 16),
                    spreadRadius: 0,
                  )
                ],
                primaryColor: Colors.white,
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                showProgressBar: false,
              );
            }
          }
        } else {
          await cartInstance.insert({
            "userId": user.uuid!,
            'productId': product['productId'],
            'amount': 1
          }).whenComplete(() {
            if (mounted) {
              toastification.show(
                context: context,
                type: ToastificationType.success,
                style: ToastificationStyle.flat,
                autoCloseDuration: const Duration(seconds: 2),
                title: const Text('Item Telah Masuk Ke Keranjang 👍'),
                icon: const Icon(Icons.check),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x07000000),
                    blurRadius: 16,
                    offset: Offset(0, 16),
                    spreadRadius: 0,
                  )
                ],
                primaryColor: Colors.white,
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                showProgressBar: false,
              );

              // ScaffoldMessenger.of(context).showSnackBar(
              //     const SnackBar(content: Text('Data Sudah Terkirim 👍')));
            }
          });
        }
      }
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          style: ToastificationStyle.flat,
          autoCloseDuration: const Duration(seconds: 2),
          title: const Text('Item Gagal Dimasukkan Ke Keranjang 😢'),
          icon: const Icon(Icons.signal_cellular_no_sim_sharp),
          boxShadow: const [
            BoxShadow(
              color: Color(0x07000000),
              blurRadius: 16,
              offset: Offset(0, 16),
              spreadRadius: 0,
            )
          ],
          primaryColor: Colors.white,
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          showProgressBar: false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 40,
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(7),
            child: Container(
              color: const Color.fromARGB(255, 209, 209, 209),
              height: 1.0,
            )),
        title: Text(
          'Katalog',
          style: googleFont(fontweight: FontWeight.bold, fontsize: 24),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder(
          future: productsInstance,
          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.hasError) {
              Center(
                child: SizedBox(
                  width: 200,
                  child: AlertDialog(
                    title: const Text('Peringatan!'),
                    content: Text(
                        'Terjadi Kesalahan Error Code: ${snapshot.error.toString()}'),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: const Text('Tutup Halaman'))
                    ],
                  ),
                ),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.data!.isEmpty) {
              return const Center(child: Text('Halaman Kosong'));
            }
            return (ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final product = snapshot.data![index];
                  if (product['quantity'] < 1) {
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      child: Card(
                        color: Colors.white,
                        elevation: 3,
                        child: SizedBox(
                          height: 120,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                SizedBox(
                                    width: 90,
                                    child: Image.network(product['image'],
                                        fit: BoxFit.cover)),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${product['nama']} (Kosong)",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      height: 2,
                                    ),
                                    Text(
                                        "Harga: ${formatCurrency(product['price'])}"),
                                    Chip(
                                        label: Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          size: 15,
                                          color: Colors.yellow.shade700,
                                        ),
                                        const SizedBox(
                                          width: 3,
                                        ),
                                        Text(
                                          double.parse(
                                                  product['rating'].toString())
                                              .toString(),
                                          style: const TextStyle(fontSize: 12),
                                        )
                                      ],
                                    ))
                                  ],
                                ),
                                Expanded(
                                    child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        ClipRect(
                                          child: IconButton(
                                            onPressed: () {
                                              Navigator.push(context,
                                                  MaterialPageRoute(
                                                      builder: (context) {
                                                return ProductDetail(
                                                    product: Product(
                                                        namaProduk:
                                                            product['nama'],
                                                        deskripsiProduk: product[
                                                            'deskripsi_produk'],
                                                        price: product['price'],
                                                        image: product['image'],
                                                        rating: double.parse(
                                                            product['rating']
                                                                .toString()),
                                                        kategori: product[
                                                                'categories']
                                                            ['category'],
                                                        quantity:
                                                            product['quantity'],
                                                        productId: product[
                                                            'productId']));
                                              }));
                                            },
                                            icon: const Icon(
                                                Icons.description_outlined),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            toastification.show(
                                              context: context,
                                              type: ToastificationType.error,
                                              style: ToastificationStyle.flat,
                                              autoCloseDuration:
                                                  const Duration(seconds: 2),
                                              title:
                                                  const Text('Item Kosong 😢'),
                                              icon: const Icon(Icons
                                                  .signal_cellular_no_sim_sharp),
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Color(0x07000000),
                                                  blurRadius: 16,
                                                  offset: Offset(0, 16),
                                                  spreadRadius: 0,
                                                )
                                              ],
                                              primaryColor: Colors.white,
                                              backgroundColor: Colors.red,
                                              foregroundColor: Colors.white,
                                              showProgressBar: false,
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.shopping_cart_outlined,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ))
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  return Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: Card(
                      color: Colors.white,
                      elevation: 3,
                      child: SizedBox(
                        height: 120,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              SizedBox(
                                  width: 90,
                                  child: Image.network(product['image'],
                                      fit: BoxFit.cover)),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    product['nama'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 2,
                                  ),
                                  Text(
                                      "Harga: ${formatCurrency(product['price'])}"),
                                  Chip(
                                      label: Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        size: 15,
                                        color: Colors.yellow.shade700,
                                      ),
                                      const SizedBox(
                                        width: 3,
                                      ),
                                      Text(
                                        double.parse(
                                                product['rating'].toString())
                                            .toString(),
                                        style: const TextStyle(fontSize: 12),
                                      )
                                    ],
                                  ))
                                ],
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            Navigator.push(context,
                                                MaterialPageRoute(
                                                    builder: (context) {
                                              return ProductDetail(
                                                  product: Product(
                                                      namaProduk:
                                                          product['nama'],
                                                      deskripsiProduk: product[
                                                          'deskripsi_produk'],
                                                      price: product['price'],
                                                      image: product['image'],
                                                      rating: double.parse(
                                                          product['rating']
                                                              .toString()),
                                                      kategori:
                                                          product['categories']
                                                              ['category'],
                                                      quantity:
                                                          product['quantity'],
                                                      productId: product[
                                                          'productId']));
                                            }));
                                          },
                                          icon: const Icon(
                                              Icons.description_outlined),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            handleCart(product);
                                          },
                                          icon: const Icon(
                                              Icons.shopping_cart_outlined),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }));
          }),
    );
  }
}
