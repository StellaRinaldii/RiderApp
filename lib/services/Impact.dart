import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Impact {
  static const String baseUrl = 'https://impact.dei.unipd.it/bwthw/';
  static const String tokenEndpoint = 'gate/v1/token/';
  static const String refreshEndpoint = 'gate/v1/refresh/';

  Future<int> getAndStoreTokens(String username, String password) async {
    final url = Impact.baseUrl + Impact.tokenEndpoint;

    final body = {
      'username': username,
      'password': password,
    };

    print('Calling: $url');

    final response = await http.post(
      Uri.parse(url),
      body: body,
    );

    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(response.body);

      final sp = await SharedPreferences.getInstance();

      await sp.setString('access', decodedResponse['access']);
      await sp.setString('refresh', decodedResponse['refresh']);
    }

    return response.statusCode;
  }

  Future<int> refreshTokens() async {
    final url = Impact.baseUrl + Impact.refreshEndpoint;

    final sp = await SharedPreferences.getInstance();
    final refresh = sp.getString('refresh');

    if (refresh == null) {
      return 401;
    }

    final body = {
      'refresh': refresh,
    };

    print('Calling: $url');

    final response = await http.post(
      Uri.parse(url),
      body: body,
    );

    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(response.body);

      await sp.setString('access', decodedResponse['access']);
      await sp.setString('refresh', decodedResponse['refresh']);
    }

    return response.statusCode;
  }
}