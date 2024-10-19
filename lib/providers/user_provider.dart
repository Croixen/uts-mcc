import 'package:app_penjualan_elektronik/definitions/users.dart';
import 'package:flutter/foundation.dart';

class Userproviders with ChangeNotifier, DiagnosticableTreeMixin {
  final UserCreds _user = UserCreds(email: '', username: '');

  UserCreds get user => _user;

  void setUser(uuid, email, username, imageUrl, alamat) {
    _user.uuid = uuid;
    _user.email = email;
    _user.username = username;
    _user.urlFoto = imageUrl;
    _user.alamat = alamat ?? '';
    notifyListeners();
  }

  /// Makes `Counter` readable inside the devtools by listing all of its properties
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('uuid', _user.uuid));
  }
}
