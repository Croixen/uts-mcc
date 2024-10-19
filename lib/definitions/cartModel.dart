class CartModel {
  String cartId;
  Map<String, dynamic> products;
  int amount;

  CartModel(
      {required this.cartId, required this.products, required this.amount});
}
