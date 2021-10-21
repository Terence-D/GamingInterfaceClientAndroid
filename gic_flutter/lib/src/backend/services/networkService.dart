import 'dart:convert';
import 'dart:developer';

import 'package:gic_flutter/src/backend/models/networkModel.dart';
import 'package:gic_flutter/src/backend/models/screen/command.dart';
import 'package:gic_flutter/src/views/launcher/screenList.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

enum NetworkResponse { Ok, OutOfDate, Error, Unauthorized }

class NetworkService {
  static final String serverApiVersion = "2.1.0.0";

  static Future<NetworkResponse> sendCommand(
      NetworkModel networkModel, String command, Command keystroke) async {
    String basicAuth =
        base64Encode(Latin1Codec().encode('gic:${networkModel.password}'));
    Map<String, String> headers = Map();
    headers['Content-Type'] = 'application/json; charset=UTF-8';
    headers["Authorization"] = 'Basic $basicAuth';

    String body = json.encode(keystroke); //.toJson();
    NetworkResponse response = await http
        .post(
            Uri.http("${networkModel.address}:${networkModel.port}",
                "/api/$command"),
            body: body,
            headers: headers)
        .timeout(const Duration(seconds: 5))
        .then((response) {
          if (response.statusCode != 401)
            return NetworkResponse.Ok;
          else
            return NetworkResponse.Unauthorized;
    }).catchError((err) {
      log(err.toString());
      return NetworkResponse.Error;
    });

    return response;
  }

  static Future<NetworkResponse> checkVersion(NetworkModel networkModel) async {
    Uri url  = Uri.http("${networkModel.address}:${networkModel.port}", "api/version");
    try {
      Response response = await http.post(url);

      if (response != null && response.statusCode == 200) {
        // If the server did return a 200 OK response then parse the JSON.
        VersionResponse versionResponse =VersionResponse.fromJson(jsonDecode(response.body));
        if (versionResponse.version == serverApiVersion) {
          return NetworkResponse.Ok;
        } else {
          return NetworkResponse.OutOfDate;
        }
      } else
        return NetworkResponse.Error;
    } catch (exception) {
      return NetworkResponse.Error;
    }
  }
}
