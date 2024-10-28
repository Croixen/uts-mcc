import 'package:app_penjualan_elektronik/definitions/cartModel.dart';
import 'package:app_penjualan_elektronik/pages/transactionPages/detail_pembayaran.dart';
import 'package:app_penjualan_elektronik/providers/cart_provider.dart';
import 'package:app_penjualan_elektronik/providers/user_provider.dart';
import 'package:app_penjualan_elektronik/utils/fontsFactory.dart';
import 'package:app_penjualan_elektronik/utils/formatter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Cart extends StatefulWidget {
  final String uuid;
  const Cart({super.key, required this.uuid});

  @override
  State<Cart> createState() {
    return _Cart();
  }
}

class _Cart extends State<Cart> {
  List<Map<String, dynamic>>? items;
  bool _initialize = true;

  @override
  void initState() {
    super.initState();
    initPage();
  }

  void initPage() async {
    final carts = await Supabase.instance.client
        .from('cart')
        .select(
            'cartId, userId, amount, products!inner(  nama, image, price, quantity, productId)')
        .eq('userId', widget.uuid)
        .order('created_at', ascending: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_initialize) {
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
      }
      setState(() {
        items = carts;
      });
      _initialize = false;
      Provider.of<CartProvider>(context, listen: false).initCart(itemToMap());
      Navigator.pop(context);
    });
  }

  void handleDelete(String cartId) async {
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
      final response = await Supabase.instance.client
          .from('cart')
          .delete()
          .eq('cartId', cartId)
          .select();

      if (response.isEmpty) {
        if (mounted) {
          Navigator.pop(context);
        }
        throw Exception('Tidak Menemukan Data');
      } else {
        initPage();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Peringatan'),
                content: Text(
                    'Terjadi Kesalahan Ketika Hendak Mengirim Data, error: $e'),
              );
            });
      }
    }
  }

  void handleUpdate(String cartId) async {
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

    int currentAmount =
        Provider.of<CartProvider>(context, listen: false).getAmount(cartId);

    if (currentAmount <= 0) {
      await Supabase.instance.client.from('cart').delete().eq('cartId', cartId);

      setState(() {
        items?.removeWhere((item) => item['cartId'] == cartId);
      });
    } else {
      await Supabase.instance.client
          .from('cart')
          .update({'amount': currentAmount}).eq('cartId', cartId);
    }

    // Refresh the UI
    initPage();
  }

  List<CartModel> itemToMap() {
    List<CartModel> cartList = (items as List).map((item) {
      return CartModel(
        cartId: item['cartId'],
        products: {
          'productId': item['products']['productId'],
          'nama': item['products']['nama'],
          'price': item['products']['price'],
          'image': item['products']['image'],
          'quantity': item['products']['quantity']
        },
        amount: item['amount'],
      );
    }).toList();

    return cartList;
  }

  @override
  Widget build(BuildContext context) {
    if (items == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (items!.isEmpty) {
      return Scaffold(
        body: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(15.0),
              child: Center(
                  child: Text(
                'Tidak ada apa-apa di dalam keranjang anda 😢',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              )),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.black, width: 1))),
          child: Container(
            margin: const EdgeInsets.fromLTRB(40, 10, 40, 10),
            child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Tutup',
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: Container(
              height: 1,
              color: const Color.fromARGB(255, 194, 194, 194),
            )),
        elevation: 2,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back)),
        centerTitle: true,
        title: Text(
          'Cart',
          style: googleFont(fontweight: FontWeight.bold, fontsize: 20),
        ),
      ),
      body: Builder(
        builder: (context) {
          return ListView.builder(
            itemCount: items!.length,
            itemBuilder: (context, index) {
              final cartData = items![index];

              if (context.watch<CartProvider>().getAmount(cartData['cartId']) <=
                  0) {
                return const SizedBox.shrink();
              }

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Card(
                  color: Colors.white,
                  elevation: 3,
                  child: SizedBox(
                    height: 130,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          SizedBox(
                              width: 90,
                              child: Image.network(
                                  cartData['products']['image'],
                                  fit: BoxFit.cover)),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                cartData['products']['nama'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              Text(
                                  "Harga: ${context.watch<CartProvider>().getAmount(cartData['cartId'])}@${formatCurrency(cartData['products']['price'])}"),
                              Text(
                                  "Total: ${formatCurrency((context.watch<CartProvider>().getAmount(cartData['cartId']) * cartData['products']['price']).toInt())}"),
                              Expanded(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          context
                                              .read<CartProvider>()
                                              .decrementAmount(
                                                  cartData['cartId']);
                                          handleUpdate(cartData['cartId']);
                                        },
                                        icon: const Icon(Icons.remove),
                                      ),
                                      Text(
                                        '${context.watch<CartProvider>().getAmount(cartData['cartId'])}',
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          context
                                              .read<CartProvider>()
                                              .incrementAmount(
                                                  cartData['cartId']);

                                          handleUpdate(cartData['cartId']);
                                        },
                                        icon: const Icon(Icons.add),
                                      ),
                                      const SizedBox(width: 10),
                                      IconButton(
                                        onPressed: () {
                                          handleDelete(cartData['cartId']);
                                        },
                                        icon: const Icon(
                                            Icons.restore_from_trash),
                                        color: Colors.red,
                                      )
                                    ],
                                  ),
                                ],
                              ))
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Provider.of<Userproviders>(context).user.alamat != ''
          ? Container(
              decoration: const BoxDecoration(
                  border: Border(
                      top: BorderSide(
                          color: Color.fromARGB(255, 184, 184, 184),
                          width: 1))),
              child: Container(
                margin: const EdgeInsets.fromLTRB(40, 10, 40, 10),
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          settings: const RouteSettings(name: 'transaction'),
                          builder: (context) => Pay(
                              sum: Provider.of<CartProvider>(context,
                                      listen: false)
                                  .sum
                                  .toInt())));
                    },
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.shopping_bag_rounded),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            formatCurrency(
                                context.watch<CartProvider>().sum.toInt()),
                            style: googleFont(
                                fontsize: 18,
                                fontweight: FontWeight.bold,
                                colour: Colors.white),
                          )
                        ],
                      ),
                    )),
              ))
          : Container(
              decoration: const BoxDecoration(
                  border: Border(
                      top: BorderSide(
                          color: Color.fromARGB(255, 196, 196, 196),
                          width: 1))),
              child: Container(
                margin: const EdgeInsets.fromLTRB(40, 10, 40, 10),
                child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Alamat Tidak Ditemukan'),
                            content: const Text(
                                'Mohon Isi Alamat Profil Terlebih Dahulu'),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Tutup'))
                            ],
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        'Profil Tidak Memiliki Alamat',
                        style: googleFont(
                            fontsize: 18,
                            fontweight: FontWeight.bold,
                            colour: Colors.white),
                      ),
                    )),
              )),
    );
  }
}
