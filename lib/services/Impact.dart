import 'dart:io';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Impact {
  static const String baseUrl = 'https://impact.dei.unipd.it/bwthw/';
  static const String tokenEndpoint = 'gate/v1/token/';
  static const String refreshEndpoint = 'gate/v1/refresh/';
  static const String exerciseEndpoint = 'data/v1/exercise/patients/';

  static String patientUsername = 'Jpefaq6m58';

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

  // Fetch exercise data for a single day
  static Future<dynamic> fetchExerciseDataByDay({
    required String day,
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
    final url = Impact.baseUrl + Impact.exerciseEndpoint + Impact.patientUsername + '/day/$day/';

    final headers = {HttpHeaders.authorizationHeader: 'Bearer $access'};

    //Get the response
    print('Calling: $url');
    final response = await http.get(Uri.parse(url), headers: headers);
    
    //if OK parse the response, otherwise return null
    var result = null;
    if (response.statusCode == 200) {
      result = jsonDecode(response.body);
    } //if

    //Return the result
    return result;

  } //fetchExerciseDataByDay
  

  // Fetch exercise data for a date range.
  // OSS: The API accepts a maximum range of 7 days.
  static Future<dynamic> fetchExerciseDataByDateRange({
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
    final url = Impact.baseUrl + Impact.exerciseEndpoint + Impact.patientUsername
        + '/daterange/start_date/$startDate/end_date/$endDate/';

    final headers = {HttpHeaders.authorizationHeader: 'Bearer $access'};

    //Get the response
    print('Calling: $url');
    final response = await http.get(Uri.parse(url), headers: headers);
    
    //if OK parse the response, otherwise return null
    var result = null;
    if (response.statusCode == 200) {
      result = jsonDecode(response.body);
    } //if

    //Return the result
    print('Received data: $result');
    return result;

  } //fetchExerciseDataByDateRange

}