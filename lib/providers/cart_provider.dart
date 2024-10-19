import 'package:app_penjualan_elektronik/definitions/cartModel.dart';
import 'package:flutter/foundation.dart';

class CartProvider with ChangeNotifier, DiagnosticableTreeMixin {
  List<CartModel> _cartItems = [];

  List<CartModel> get cartItem => _cartItems;

  int getAmount(String cartId) {
    try {
      return _cartItems
          .firstWhere((cartItem) => cartItem.cartId == cartId)
          .amount;
    } catch (e) {
      return 0; // Return 0 if the item is not found
    }
  }

  void initCart(List<CartModel> cart) {
    _cartItems = cart;
    notifyListeners();
  }

  double get sum => _cartItems.fold(0.0, (total, item) {
        final price = double.tryParse(item.products['price'].toString()) ??
            0.0; //biarin kagak unexpected aneh aneh...
        return total + (price * item.amount);
      });

  void incrementAmount(
    String cartId,
  ) {
    final item = _cartItems.firstWhere((cartItem) => cartItem.cartId == cartId);
    item.amount++;
    notifyListeners();
  }

  void decrementAmount(String cartId) {
    final item = _cartItems.firstWhere((cartItem) => cartItem.cartId == cartId);
    if (item.amount > 1) {
      item.amount--;
    } else {
      _cartItems.remove(item); // Remove item if amount is 1
    }
    notifyListeners();
  }

  void clearCartSum() {
    _cartItems.clear();
    notifyListeners();
  }
}
