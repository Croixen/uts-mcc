import 'package:app_penjualan_elektronik/definitions/products.dart';
import 'package:app_penjualan_elektronik/definitions/sales.dart';
import 'package:app_penjualan_elektronik/pages/productsPage/product_detail.dart';
import 'package:app_penjualan_elektronik/providers/user_provider.dart';
import 'package:app_penjualan_elektronik/utils/fontsFactory.dart';
import 'package:app_penjualan_elektronik/utils/formatter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HistoryDetail extends StatefulWidget {
  final String transactionId;
  const HistoryDetail({super.key, required this.transactionId});

  @override
  State<HistoryDetail> createState() => _HistoryDetail();
}

class _HistoryDetail extends State<HistoryDetail> {
  List<Sales> history = [];

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  void fetchHistory() async {
    try {
      final salesInstance = await Supabase.instance.client
          .from('sales')
          .select('*,products!inner(*), transactions!inner(*)')
          .eq('uuid',
              Provider.of<Userproviders>(context, listen: false).user.uuid!)
          .eq('transactionId', widget.transactionId);

      if (salesInstance.isNotEmpty) {
        convertDataToObject(salesInstance);
      }
    } catch (e) {
      if (mounted) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Peringatan'),
                content: Text('Terjadi Kesalahan: $e'),
              );
            });
      }
    }
  }

  void convertDataToObject(List<Map<String, dynamic>> toConvert) async {
    final productInstance = Supabase.instance.client.from('categories');
    List<Sales> newState = [];
    for (Map<String, dynamic> item in toConvert) {
      final kategori = await productInstance
          .select("category")
          .eq('categoryId', item['products']['kategoriId'])
          .single();
      final DateTime date = toUTC7(item['transactions']['transaction_date']);
      final Product product = Product(
        namaProduk: item['products']['nama'],
        deskripsiProduk: item['products']['deskripsi_produk'],
        price: item['products']['price'],
        image: item['products']['image'],
        rating: double.parse(item['products']['rating'].toString()),
        kategori: kategori['category'],
        quantity: item['products']['quantity'],
      );

      if (mounted) {
        final Sales toAppend = Sales(
            salesId: item['salesId'],
            transactionId: item['transactionId'],
            userId:
                Provider.of<Userproviders>(context, listen: false).user.uuid!,
            product: product,
            date: date.toString(),
            total: item['transactions']['total'],
            amount: item['amount'],
            alamat: item['transactions']['alamat']);

        newState.add(toAppend);
      }
    }

    setState(() {
      history = newState;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    DateTime date = toUTC7(history[0].date);

    return Scaffold(
      appBar: AppBar(
          toolbarHeight: 40,
          backgroundColor: Colors.white,
          titleSpacing: 5,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4.0),
            child: Container(
              color: const Color.fromARGB(255, 185, 185, 185),
              height: 1.0,
            ),
          ),
          title: Text(
            'Detail Pesanan',
            style: googleFont(fontsize: 16, fontweight: FontWeight.bold),
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
          )),
      body: Container(
        margin: const EdgeInsets.all(8),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1),
                borderRadius: BorderRadius.circular(10)),
            height: MediaQuery.of(context).size.height * 0.20,
            margin: const EdgeInsets.all(3),
            child: ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final Sales item = history[index];
                return Container(
                    padding: const EdgeInsets.all(10),
                    child: Card(
                      color: Colors.white,
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10)),
                              child: Image.network(
                                item.product.image,
                                fit: BoxFit.fill,
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.namaProduk,
                                    overflow: TextOverflow.fade,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  Text(
                                    "${item.amount} x ${formatCurrency(item.product.price)}",
                                    overflow: TextOverflow.fade,
                                    style: const TextStyle(
                                        color: Color.fromARGB(136, 61, 61, 61),
                                        fontSize: 12),
                                  ),
                                  const Divider(
                                    color: Colors.black,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Total Harga:",
                                            overflow: TextOverflow.fade,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 11),
                                          ),
                                          Text(
                                            formatCurrency(item.product.price *
                                                item.amount),
                                            overflow: TextOverflow.fade,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),
                                      IconButton(
                                          onPressed: () {
                                            Navigator.push(context,
                                                MaterialPageRoute(
                                                    builder: (context) {
                                              return ProductDetail(
                                                  product: item.product);
                                            }));
                                          },
                                          icon: const Icon(
                                              Icons.description_outlined))
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ));
              },
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Container(
              padding: const EdgeInsets.all(10),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(5)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Info Transaksi',
                    style:
                        googleFont(fontsize: 14, fontweight: FontWeight.bold),
                  ),
                  const Divider(),
                  Row(
                    children: [
                      const Text(
                        'ID Transaksi: \t',
                        overflow: TextOverflow.fade,
                        style: TextStyle(
                            fontSize: 12,
                            color: Color.fromARGB(255, 78, 78, 78)),
                      ),
                      Text(
                        widget.transactionId,
                        overflow: TextOverflow.fade,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 12),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      const Text(
                        'Tanggal Transaksi: \t',
                        overflow: TextOverflow.fade,
                        style: TextStyle(
                            fontSize: 12,
                            color: Color.fromARGB(255, 78, 78, 78)),
                      ),
                      Text(
                        "${date.year}-${date.month}-${date.day}, ${date.hour}:${date.minute}",
                        overflow: TextOverflow.fade,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 12),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      const Text(
                        'Nominal Transaksi: \t',
                        overflow: TextOverflow.fade,
                        style: TextStyle(
                            fontSize: 12,
                            color: Color.fromARGB(255, 78, 78, 78)),
                      ),
                      Text(
                        formatCurrency(history[0].total),
                        overflow: TextOverflow.fade,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 12),
                      )
                    ],
                  )
                ],
              )),
          const SizedBox(
            height: 15,
          ),
          Container(
              padding: const EdgeInsets.all(10),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(5)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detail Pengiriman',
                    style:
                        googleFont(fontsize: 14, fontweight: FontWeight.bold),
                  ),
                  const Divider(),
                  Text(history[0].alamat)
                ],
              ))
        ]),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
            border: Border(
                top: BorderSide(
                    color: Color.fromARGB(255, 221, 221, 221), width: 1))),
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)))),
              child: Container(
                padding: const EdgeInsets.all(5),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout),
                    SizedBox(
                      width: 2,
                    ),
                    Text(
                      'Tutup',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
