import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const hostDuckDuckGO = "quack.duckduckgo.com";

const duckMail = "@duck.com";

_jsonDecodeCustom(String response, int statusCode) {
  print(response);
  var json = jsonDecode(response);
  var result = {};

  if (kIsWeb) {
    if (json["contents"] != null) {
      result['contents'] = json["contents"];
    } else {
      result['contents'] = json;
    }
    result['responseCode'] = json["status"]?["http_code"] ?? 'unknown';
  } else {
    result['contents'] = json;
    result['responseCode'] = statusCode;
  }

  return result;
}

String getProxyUrl(String targetUrl) {
  if (kIsWeb) {
    return Uri.https("api.allorigins.win", "get", {'url': targetUrl})
        .toString();
  }
  return targetUrl;
}

Future<bool> loginRequest(String username) async {
  var url =
      Uri.https(hostDuckDuckGO, '/api/auth/loginlink', {'user': username});
  var requestUrl = getProxyUrl(url.toString());
  var request = http.Request('GET', Uri.parse(requestUrl));

  if (!kIsWeb) {
    request.headers.addAll({
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:128.0) Gecko/20100101 Firefox/128.0',
    });
  }

  print(request.headers);

  try {
    http.StreamedResponse response = await request.send();
    final responseString = await response.stream.bytesToString();

    print('Response body: $responseString');

    final responseJson = _jsonDecodeCustom(responseString, response.statusCode);

    if (responseJson["responseCode"] == 200) {
      return true;
    }
  } catch (e) {
    print('Error: $e');
  }
  return false;
}

Future<String> login(String username, String otp) async {
  var url = Uri.https(
      hostDuckDuckGO, '/api/auth/login', {'user': username, 'otp': otp});
  var requestUrl = getProxyUrl(url.toString());
  var request = http.Request('GET', Uri.parse(requestUrl));

  request.headers.addAll({
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:128.0) Gecko/20100101 Firefox/128.0',
  });

  try {
    http.StreamedResponse response = await request.send();
    final responseString = await response.stream.bytesToString();
    final responseJson = _jsonDecodeCustom(responseString, response.statusCode);
    print(responseJson);
    if (responseJson["responseCode"] == 200 &&
        responseJson['contents']["status"] == "authenticated") {
      var token = responseJson['contents']["token"];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('username', username);
      return token;
    }
  } catch (e) {
    print('Error: $e');
  }
  return "";
}

Future<dynamic> getDashboardTotp(String token) async {
  print(token);
  var request = http.Request(
    'GET',
    Uri.parse('https://quack.duckduckgo.com/api/email/dashboard'),
  );

  request.headers.addAll({
    'Accept': '*/*',
    'Authorization': 'Bearer $token',
  });

  try {
    http.StreamedResponse response = await request.send();
    final responseString = await response.stream.bytesToString();
    print('Risposta raw: $responseString');
    var responseJson = _jsonDecodeCustom(responseString, response.statusCode);
    print('Risposta JSON: $responseJson');
    if (responseJson["responseCode"] == 200) {
      if (responseJson['contents']["user"]["access_token"] != null) {
        var jsonOutput = {};
        jsonOutput["otp"] = responseJson['contents']["user"]["access_token"];
        jsonOutput["email"] = responseJson['contents']["user"]["email"];
        return jsonOutput;
      }
    }
  } catch (e) {
    print('Error: $e');
  }
  return "null";
}

Future<String> generate(String username, String token) async {
  var request = http.Request(
    'POST',
    Uri.parse('https://quack.duckduckgo.com/api/email/addresses'),
  );

  request.headers.addAll({
    'Accept': '*/*',
    'Authorization': 'Bearer $token',
  });

  try {
    http.StreamedResponse response = await request.send();
    final responseString = await response.stream.bytesToString();
    print(responseString);
    final responseJson = _jsonDecodeCustom(responseString, response.statusCode);
    print(responseJson);
    if ((response.statusCode == 201) && (responseJson['contents']["address"] != null)) {
      return responseJson['contents']["address"] + duckMail;
    }
  } catch (e) {
    print('Error: $e');
  }
  return "null";
}
