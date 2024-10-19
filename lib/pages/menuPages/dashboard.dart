import 'package:app_penjualan_elektronik/pages/productsPage/katalog.dart';
import 'package:app_penjualan_elektronik/utils/fontsFactory.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _Dashboard();
}

class _Dashboard extends State<Dashboard> {
  final _future = Supabase.instance.client
      .from('products')
      .select()
      .eq('rating', 5)
      .limit(5);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            showDialog(
                context: context,
                builder: (context) {
                  return const AlertDialog(
                    title: Text('Peringatan!'),
                    content: Text('Gagal Dalam Mengambil Data'),
                  );
                });
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Container(
                  decoration: const BoxDecoration(boxShadow: [
                    BoxShadow(
                        color: Colors.black,
                        offset: Offset(0, 4),
                        blurStyle: BlurStyle.outer,
                        blurRadius: 0.5,
                        spreadRadius: 0.6)
                  ]),
                  child: CarouselSlider(
                    options: CarouselOptions(
                        height: 200.0,
                        autoPlay: true,
                        pauseAutoPlayInFiniteScroll: false,
                        autoPlayInterval: const Duration(seconds: 2),
                        aspectRatio: 100),
                    items: snapshot.data!.map((item) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                              width: (MediaQuery.of(context).size.width),
                              height:
                                  (MediaQuery.of(context).size.height * 0.1),
                              decoration:
                                  const BoxDecoration(color: Colors.white),
                              child: Image.network(item['image']));
                        },
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  'Product Categories',
                  style: googleFont(
                      fontsize: 24,
                      colour: Colors.grey,
                      fontweight: FontWeight.bold),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: GridView.count(
                    shrinkWrap: true,
                    primary: false,
                    padding: const EdgeInsets.all(20),
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                    crossAxisCount: 2,
                    children: [
                      categoriesCardGen(
                          title: 'Komputer',
                          imageUri:
                              'https://iqgrsjddtctvxxqkoxro.supabase.co/storage/v1/object/public/images/produk/hpComputer.jpg'),
                      categoriesCardGen(
                          title: 'Perkakas Perbaikan Elektronik',
                          imageUri:
                              'https://iqgrsjddtctvxxqkoxro.supabase.co/storage/v1/object/public/images/produk/screwdriver.jpg'),
                      categoriesCardGen(
                          title: 'Perlengkapan Dapur',
                          imageUri:
                              'https://iqgrsjddtctvxxqkoxro.supabase.co/storage/v1/object/public/images/produk/microwave.jpg'),
                      categoriesCardGen(
                          title: 'Home Appliances',
                          imageUri:
                              'https://iqgrsjddtctvxxqkoxro.supabase.co/storage/v1/object/public/images/produk/Air_Conditioner.jpg'),
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }

  GestureDetector categoriesCardGen(
      {required String title, required String imageUri}) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => Katalog(kategori: title),
        ));
      },
      child: Card(
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  image: DecorationImage(image: NetworkImage(imageUri))),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.black.withOpacity(0.4),
              ),
              child: Center(
                child: Text(
                  title,
                  style: googleFont(
                      colour: Colors.white,
                      fontweight: FontWeight.bold,
                      fontsize: 16),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
