class Product {
  String? productId;
  String namaProduk;
  String deskripsiProduk;
  int price;
  String image;
  double rating;
  String kategori;
  int quantity;

  Product(
      {required this.namaProduk,
      required this.deskripsiProduk,
      required this.price,
      required this.image,
      required this.rating,
      required this.kategori,
      required this.quantity,
      this.productId});

  Map<String, dynamic> toMap() {
    return {
      'quantity': quantity,
      'nama': namaProduk,
      'deskripsi_produk': deskripsiProduk,
      'price': price,
      'image': image,
      'rating': rating,
      'productId': productId,
    };
  }
}
