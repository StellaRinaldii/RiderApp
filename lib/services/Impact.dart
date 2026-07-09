import 'dart:io';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/exercise_activity.dart';
import '../models/resting_heart_rate.dart';
import '../models/sleep_data.dart';
import 'package:intl/intl.dart';

class Impact {
  static const String baseUrl = 'https://impact.dei.unipd.it/bwthw/';
  static const String tokenEndpoint = 'gate/v1/token/';
  static const String refreshEndpoint = 'gate/v1/refresh/';
  static const String exerciseEndpoint = 'data/v1/exercise/patients/';
  static const String restingHeartRateEndpoint = 'data/v1/resting_heart_rate/patients/';
  static const String sleepEndpoint = 'data/v1/sleep/patients/';

  static String patientUsername = 'Jpefaq6m58';
  static String formatDate(DateTime date) {
  return DateFormat('yyyy-MM-dd').format(date);
}
// This method allows to get the JWT from Impact and store it in SharedPreferences
  Future<int> getAndStoreTokens(String username, String password) async {
    //Create the request
    final url = Impact.baseUrl + Impact.tokenEndpoint;
    final body = {'username': username, 'password': password};

    //Get the response
    print('Calling: $url');
    final response = await http.post(Uri.parse(url), body: body);

    //If response is OK, decode it and store the tokens. Otherwise do nothing.
    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(response.body);
      final sp = await SharedPreferences.getInstance();
      await sp.setString('access', decodedResponse['access']);
      await sp.setString('refresh', decodedResponse['refresh']);
    } //if

    //Just return the status code
    return response.statusCode;
  } //_getAndStoreTokens

  //This method allows to refresh the stored JWT in SharedPreferences
  static Future<int> refreshTokens() async {
    //Create the request
    final url = Impact.baseUrl + Impact.refreshEndpoint;
    final sp = await SharedPreferences.getInstance();
    final refresh = sp.getString('refresh');
    if (refresh != null) {
      final body = {'refresh': refresh};

      //Get the response
      print('Calling: $url');
      final response = await http.post(Uri.parse(url), body: body);

      //If the response is OK, set the tokens in SharedPreferences to the new values
      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        final sp = await SharedPreferences.getInstance();
        await sp.setString('access', decodedResponse['access']);
        await sp.setString('refresh', decodedResponse['refresh']);
      } //if

      //Just return the status code
      return response.statusCode;
    }
    return 401;
  } //_refreshTokens  

  // This method fetches exercise data for a date range.
  // OSS: The API accepts a maximum range of 7 days.
  static Future<List<ExerciseActivity>?> fetchExerciseDataByDateRange({
    required String startDate,
    required String endDate,
  }) async {

    //Get the stored access token (Note that this code does not work if the tokens are null)
    final sp = await SharedPreferences.getInstance();
    var access = sp.getString('access');

    //If access token is expired, refresh it
    if(JwtDecoder.isExpired(access!)){
      await Impact.refreshTokens();
      access = sp.getString('access');
    }//if

    //Create the request
    final url = Impact.baseUrl + Impact.exerciseEndpoint + Impact.patientUsername + '/daterange/start_date/$startDate/end_date/$endDate/';

    final headers = {HttpHeaders.authorizationHeader: 'Bearer $access'};

    print('Calling: $url');
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode != 200) {
      return null;
    }

    final decodedResponse = jsonDecode(response.body);

    final List<ExerciseActivity> activities = [];

    final days = decodedResponse is List
        ? decodedResponse
        : decodedResponse is Map
            ? decodedResponse['data']
            : null;

    if (days is List) {
      for (final day in days) {
        if (day is! Map) continue;

        final date = day['date']?.toString() ?? '';
        final data = day['data'];

        if (data is List) {
          for (final item in data) {
            if (item is! Map) continue;

            activities.add(
              ExerciseActivity.fromJson(
                Map<String, dynamic>.from(item),
                date,
              ),
            );
          }
        }
      }
    }

    print('Number of activities: ${activities.length}');

    return activities;

  } //fetchExerciseDataByDateRange

  // This method fetches the resting heart rate recorded for a single day.
  // Returns null if the request fails or if no data is available for that day.
  static Future<RestingHeartRate?> fetchRestingHeartRateByDate(String date) async {

    final sp = await SharedPreferences.getInstance();
    var access = sp.getString('access');

    if (JwtDecoder.isExpired(access!)) {
      await Impact.refreshTokens();
      access = sp.getString('access');
    }//if

    final url = Impact.baseUrl + Impact.restingHeartRateEndpoint + Impact.patientUsername + '/day/$date/';

    final headers = {HttpHeaders.authorizationHeader: 'Bearer $access'};

    print('Calling: $url');
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode != 200) {
      return null;
    }

    final decodedResponse = jsonDecode(response.body);

    final dayData = decodedResponse is Map ? decodedResponse['data'] : null;
    final readings = dayData is Map ? dayData['data'] : null;

    if (readings is! List || readings.isEmpty) {
      return null;
    }

    return RestingHeartRate.fromJson(Map<String, dynamic>.from(readings.first));

  } //fetchRestingHeartRateByDate

  // This method fetches the sleep data recorded for a single day.
  // Returns null if the request fails or if no data is available for that day.
  static Future<SleepData?> fetchSleepDataByDate(String date) async {

    final sp = await SharedPreferences.getInstance();
    var access = sp.getString('access');

    if (JwtDecoder.isExpired(access!)) {
      await Impact.refreshTokens();
      access = sp.getString('access');
    }//if

    final url = Impact.baseUrl + Impact.sleepEndpoint + Impact.patientUsername + '/day/$date/';

    final headers = {HttpHeaders.authorizationHeader: 'Bearer $access'};

    print('Calling: $url');
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode != 200) {
      return null;
    }

    final decodedResponse = jsonDecode(response.body);

    final dayData = decodedResponse is Map ? decodedResponse['data'] : null;
    final readings = dayData is Map ? dayData['data'] : null;

    if (readings is! List || readings.isEmpty) {
      return null;
    }

    return SleepData.fromJson(Map<String, dynamic>.from(readings.first));

  } //fetchSleepDataByDate
}