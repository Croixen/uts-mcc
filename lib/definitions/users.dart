import 'dart:io';

class UserCreds {
  File? foto;
  String? urlFoto;
  String? uuid;
  String email;
  String? password;
  String username;
  String? alamat;

  UserCreds(
      {this.uuid,
      required this.email,
      this.password,
      required this.username,
      this.alamat});

  Map<String, dynamic> toMap() {
    if (uuid != null) {
      return {
        'uuid': uuid,
        'email': email,
        'password': password,
        'username': username,
        'image_url': urlFoto,
        'alamat': alamat
      };
    }

    return {
      'email': email,
      'password': password,
      'username': username,
      'image_url': urlFoto
    };
  }
}
