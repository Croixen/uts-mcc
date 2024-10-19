import 'package:app_penjualan_elektronik/definitions/products.dart';
import 'package:app_penjualan_elektronik/definitions/users.dart';
import 'package:app_penjualan_elektronik/providers/user_provider.dart';
import 'package:app_penjualan_elektronik/utils/fontsFactory.dart';
import 'package:flutter/material.dart';
import 'package:app_penjualan_elektronik/utils/formatter.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toastification/toastification.dart';

class ProductDetail extends StatefulWidget {
  final Product product;

  const ProductDetail({super.key, required this.product});

  @override
  State<ProductDetail> createState() {
    return _ProductDetail();
  }
}

class _ProductDetail extends State<ProductDetail> {
  Product product = Product(
      namaProduk: '',
      deskripsiProduk: '',
      price: 0,
      image: '',
      rating: 0.0,
      kategori: '',
      quantity: 0);

  final cartInstance = Supabase.instance.client.from('cart');
  UserCreds user = UserCreds(email: '', username: '');

  void handleCart(Map<String, dynamic> productMap) async {
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
      if (mounted) {
        final validation = await cartInstance
            .select('cartId, amount')
            .eq('userId', user.uuid!)
            .eq('productId', productMap['productId'])
            .maybeSingle();

        if (validation != null) {
          int prevAmount = validation['amount'];
          if (prevAmount + 1 < productMap['quantity']) {
            await cartInstance
                .update({'amount': prevAmount + 1})
                .eq('cartId', validation['cartId'])
                .whenComplete(() {
                  if (mounted) {
                    Navigator.pop(context);
                    toastification.show(
                      context: context,
                      type: ToastificationType.success,
                      style: ToastificationStyle.flat,
                      autoCloseDuration: const Duration(seconds: 2),
                      title: const Text('Item Telah Ditambahkan 👍'),
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
          if (mounted) {
            Navigator.pop(context);
          }
        } else {
          await cartInstance.insert({
            "userId": user.uuid!,
            'productId': productMap['productId'],
            'amount': 1
          }).whenComplete(() {
            Navigator.pop(context);
            if (mounted) {
              toastification.show(
                context: context,
                type: ToastificationType.success,
                style: ToastificationStyle.flat,
                autoCloseDuration: const Duration(seconds: 2),
                title: const Text('Item Telah Ditambahkan Ke Keranjang 👍'),
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
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);

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
  void initState() {
    super.initState();
    product = widget.product;
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      user = Provider.of<Userproviders>(context).user;
    });
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 5,
        toolbarHeight: MediaQuery.of(context).size.height * 0.07,
        elevation: 2,
        title: Text(
          'Informasi Produk',
          style: googleFont(fontsize: 16, fontweight: FontWeight.bold),
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back)),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: const BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: Colors.black, width: 1))),
              margin: const EdgeInsets.all(5),
              height: 290,
              width: MediaQuery.of(context).size.width,
              child: Image.network(
                product.image,
                fit: BoxFit.fill,
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(10, 5, 10, 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(formatCurrency(product.price),
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(
                    product.namaProduk,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.green.shade700, width: 1),
                  borderRadius: BorderRadius.circular(20)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detail Produk',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 7,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Chip(
                          elevation: 3,
                          label: Row(
                            children: [
                              const Icon(
                                Icons.category,
                                size: 15,
                              ),
                              const SizedBox(
                                width: 3,
                              ),
                              Text(product.kategori,
                                  style: const TextStyle(fontSize: 12))
                            ],
                          )),
                      const SizedBox(
                        width: 3,
                      ),
                      Chip(
                          elevation: 3,
                          label: Row(
                            children: [
                              const Icon(
                                Icons.warehouse,
                                size: 15,
                              ),
                              const SizedBox(
                                width: 3,
                              ),
                              Text(
                                product.quantity.toString(),
                                style: const TextStyle(fontSize: 12),
                              )
                            ],
                          )),
                      const SizedBox(
                        width: 5,
                      ),
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
                            product.rating.toString(),
                            style: const TextStyle(fontSize: 12),
                          )
                        ],
                      ))
                    ],
                  ),
                  const SizedBox(
                    height: 7,
                  ),
                  const Text(
                    'Deskripsi Produk',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(product.deskripsiProduk),
                ],
              ),
            ),
            SizedBox(
              height: (MediaQuery.of(context).size.height * 0.1),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Colors.black, width: 1))),
        child: Container(
          margin: const EdgeInsets.fromLTRB(40, 10, 40, 10),
          child: product.quantity < 1
              ? ElevatedButton(
                  onPressed: () {
                    toastification.show(
                      context: context,
                      type: ToastificationType.error,
                      style: ToastificationStyle.flat,
                      autoCloseDuration: const Duration(seconds: 2),
                      title: const Text('Item Kosong 😢'),
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
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Barang Kosong',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ))
              : ElevatedButton(
                  onPressed: () {
                    handleCart(product.toMap());
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_rounded),
                        SizedBox(
                          width: 3,
                        ),
                        Text(
                          'Beli',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  )),
        ),
      ),
    );
  }
}
