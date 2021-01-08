import 'dart:convert';
import 'dart:developer';
import 'package:gic_flutter/src/backend/models/networkModel.dart';
import 'package:gic_flutter/src/views/launcher/screenList.dart';
import 'package:http/http.dart' as http;
import 'package:gic_flutter/src/backend/models/screen/command.dart';

enum NetworkResponse {
    Ok,
    OutOfDate,
    Error
}

class NetworkService {

    static final String serverApiVersion = "2.1.0.0";

    static Future<NetworkResponse> sendCommand(NetworkModel networkModel, String command, Command keystroke) async {
        String basicAuth = base64Encode(Latin1Codec().encode('gic:${networkModel.password}'));
        Map<String, String> headers = new Map();
        headers['Content-Type'] = 'application/json; charset=UTF-8';
        headers["Authorization"] = 'Basic $basicAuth';

        String body = json.encode(keystroke);//.toJson();
        await http.post(new Uri.http("${networkModel.address}:${networkModel.port}", "/api/$command"), body: body, headers:headers)
            .timeout(const Duration(seconds: 5))
            .then((response) {
                return NetworkResponse.Ok;
            }).catchError((err) {
                log(err.toString());
                return NetworkResponse.Error;
            }
        );
    }

    static Future<NetworkResponse> checkVersion(NetworkModel networkModel) async {
        return await http.post(new Uri.http("${networkModel.address}:${networkModel.port}", "api/version"))
            .timeout(const Duration(seconds: 30)).then((response) {
            if (response != null && response.statusCode == 200) {
                // If the server did return a 200 OK response then parse the JSON.
                VersionResponse versionResponse = VersionResponse.fromJson(jsonDecode(response.body));
                if (versionResponse.version == serverApiVersion)
                    return NetworkResponse.Ok;
            }
            return NetworkResponse.OutOfDate;
       }).catchError((err) {
            log(err.toString());
            return NetworkResponse.Error;
        });
    }
}