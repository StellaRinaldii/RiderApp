import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Impact {
  static const String baseUrl = 'https://impact.dei.unipd.it/bwthw/';
  static const String tokenEndpoint = 'gate/v1/token/';
  static const String refreshEndpoint = 'gate/v1/refresh/';
  static const String exerciseEndpoint = 'data/v1/exercise/patients/';

  static String patientUsername = 'Jpefaq6m58'; // username is the same for every group!

  // Get tokens from IMPACT and store them in SharedPreferences
  Future<int> getAndStoreTokens(String username, String password) async {
    final url = Impact.baseUrl + Impact.tokenEndpoint;

    final response = await http.post(
      Uri.parse(url),
      body: {
        'username': username,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final d = jsonDecode(response.body);
      final sp = await SharedPreferences.getInstance();

      await sp.setString('access', d['access']);
      await sp.setString('refresh', d['refresh']);
    }

    return response.statusCode;
  }

  // Refresh the access token using the refresh token
  Future<int> refreshTokens() async {
    final sp = await SharedPreferences.getInstance();
    final refresh = sp.getString('refresh');

    if (refresh == null) return 401;

    final url = Impact.baseUrl + Impact.refreshEndpoint;

    final response = await http.post(
      Uri.parse(url),
      body: {
        'refresh': refresh,
      },
    );

    if (response.statusCode == 200) {
      final d = jsonDecode(response.body);

      await sp.setString('access', d['access']);
      await sp.setString('refresh', d['refresh']);
    }

    return response.statusCode;
  }

  // Build auth headers from stored access token
  static Future<Map<String, String>> _headers() async {
    final sp = await SharedPreferences.getInstance();
    final access = sp.getString('access') ?? '';

    return {
      'Authorization': 'Bearer $access',
    };
  }

  // Fetch exercise data for a single day
  static Future<dynamic> fetchExerciseDataByDay({
    required String username,
    required String day,
  }) async {
    final url = '${Impact.baseUrl}${Impact.exerciseEndpoint}$username/day/$day/';

    print('Calling: $url');

    var response = await http.get(
      Uri.parse(url),
      headers: await _headers(),
    );

    if (response.statusCode == 401) {
      await Impact().refreshTokens();

      response = await http.get(
        Uri.parse(url),
        headers: await _headers(),
      );
    }

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    print('fetchExerciseDataByDay error: ${response.statusCode}');
    return null;
  }

  // Fetch exercise data for a date range.
  // The API accepts a maximum range of 7 days.
  static Future<dynamic> fetchExerciseDataByDateRange({
    required String username,
    required String startDate,
    required String endDate,
  }) async {
    final url = '${Impact.baseUrl}${Impact.exerciseEndpoint}$username'
        '/daterange/start_date/$startDate/end_date/$endDate/';

    print('Calling: $url');

    var response = await http.get(
      Uri.parse(url),
      headers: await _headers(),
    );

    if (response.statusCode == 401) {
      await Impact().refreshTokens();

      response = await http.get(
        Uri.parse(url),
        headers: await _headers(),
      );
    }

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    print('fetchExerciseDataByDateRange error: ${response.statusCode}');
    return null;
  }
}