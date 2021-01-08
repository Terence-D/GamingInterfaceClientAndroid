import 'package:gic_flutter/src/backend/services/cryptoService.dart';

class NetworkModel {
    String _password;
    String _address;
    String _port;

    String get password => _password;
    String get address => _address;
    String get port => _port;

    Future init(String unencryptedPassword, String address, String port) async {
        _password = await CryptoService.encrypt(unencryptedPassword);
        _address = address;
        _port = port;
    }
}