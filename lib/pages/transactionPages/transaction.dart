import 'package:app_penjualan_elektronik/definitions/cartModel.dart';
import 'package:app_penjualan_elektronik/pages/transactionPages/payment.dart';
import 'package:app_penjualan_elektronik/providers/cart_provider.dart';
import 'package:app_penjualan_elektronik/utils/fontsFactory.dart';
import 'package:app_penjualan_elektronik/utils/formatter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Pay extends StatefulWidget {
  final int sum;
  const Pay({super.key, required this.sum});

  @override
  State<Pay> createState() {
    return _Pay();
  }
}

class _Pay extends State<Pay> {
  List<CartModel> cartLoad = [];

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

  void handleTransaction() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Payment(
            sum: widget.sum,
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          bottom: PreferredSize(
              preferredSize: const Size.fromHeight(4),
              child: Container(
                color: const Color.fromARGB(255, 192, 192, 192),
                height: 1,
              )),
          title: Text(
            'Transaksi',
            style: googleFont(fontweight: FontWeight.bold, fontsize: 18),
          ),
          centerTitle: true,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_rounded)),
        ),
        body: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 1),
          ),
          height: MediaQuery.of(context).size.height * 0.75,
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              const Text(
                'Detail Pembayaran:',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              cartLoad.isNotEmpty
                  ? ListView.builder(
                      itemCount: cartLoad.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final cartItem = cartLoad[index];
                        if (cartItem.cartId.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return (Text(
                            '${cartItem.products['nama']}: ${cartItem.amount} x ${formatCurrency(cartItem.products['price'])}'));
                      },
                    )
                  : Center(
                      child: Text(
                          'Tidak ada barang di keranjang anda! ${cartLoad.length}'),
                    ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  children: [
                    const Text(
                      'Total: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(formatCurrency(widget.sum.toInt())),
                  ],
                ),
              )
            ],
          ),
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
              border: Border(
                  top: BorderSide(
                      color: Color.fromARGB(255, 177, 177, 177), width: 1))),
          child: Container(
            margin: const EdgeInsets.fromLTRB(40, 10, 40, 10),
            child: ElevatedButton(
                onPressed: () {
                  handleTransaction();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Konfirmasi Transaksi',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                )),
          ),
        ));
  }
}
