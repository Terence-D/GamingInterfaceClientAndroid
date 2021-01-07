import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:gic_flutter/src/backend/models/screen/command.dart';

import 'cryptoService.dart';

class NetworkService {
    static String password;
    static String address;
    static String port;

    static Future<void> SendCommand(String command, Command keystroke) async {
        String encrypted = await CryptoService.encrypt(password);
        String basicAuth = base64Encode(Latin1Codec().encode('gic:$encrypted'));
        Map<String, String> headers = new Map();
        headers["Authorization"] = 'Basic $basicAuth';
        String body = json.encode(keystroke.toJson());
        await http.post(new Uri.http("$address:$port", "/api/$command"), body: body, headers:headers)
            .timeout(const Duration(seconds: 30)).then((response) {
                log(response.statusCode.toString());
                if(response.statusCode == 200) {
                }else {
                }
            }).catchError((err) {
                log(err.toString());
        });

    }
}