import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const hostDuckDuckGO = "quack.duckduckgo.com";

String getProxyUrl(String targetUrl) {
  if (kIsWeb) {
    return Uri.https("api.allorigins.win", "raw", {'url': targetUrl}).toString();
  }
  return targetUrl;
}

Future<bool> loginRequest(String username) async {
  var url = Uri.https(hostDuckDuckGO, '/api/auth/loginlink', {'user': username});
  var requestUrl = getProxyUrl(url.toString());
  var request = http.Request('GET', Uri.parse(requestUrl));

  if(!kIsWeb){
    request.headers.addAll({
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:128.0) Gecko/20100101 Firefox/128.0',
    });
  }
  request.headers.addAll({
    'Accept': '*/*',
  });

  print(request.headers);

  try {
    http.StreamedResponse response = await request.send();
    final responseString = await response.stream.bytesToString();
    if (kDebugMode) {
      print('Response status: ${response.statusCode}');
    }
    if (kDebugMode) {
      print('Response body: $responseString');
    }
    if (response.statusCode == 200) {
      if (kIsWeb) {
        final responseJson = jsonDecode(responseString);
        if (kDebugMode) {
          print(responseJson);
        }
        if(responseJson["status"]["http_code"] != null && responseJson["status"]["http_code"] == 200){
          return true;
        }else{
          return false;
        }
      }else{
        return true;
      }

    }
  } catch (e) {
    print('Error: $e');
  }
  return false;
}


jsonDecodeCustom(String response) {
  var json = jsonDecode(response);
  if (kIsWeb) {
    if(json["contents"]!= null){
      json =  json["contents"];
    }
  }
  return json;
}

Future<String> login(String username, String otp) async {
  var url = Uri.https(hostDuckDuckGO, '/api/auth/login', {'user': username, 'otp': otp});
  var requestUrl = getProxyUrl(url.toString());
  var request = http.Request('GET', Uri.parse(requestUrl));

  request.headers.addAll({
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:128.0) Gecko/20100101 Firefox/128.0',
  });

  try {
    http.StreamedResponse response = await request.send();
    final responseString = await response.stream.bytesToString();
    final responseJson = jsonDecodeCustom(responseString);
    print(responseJson);
    if (response.statusCode == 200 && responseJson["status"] == "authenticated") {
      var token = responseJson["token"];
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

Future<String> getDashboardTotp(String token) async {
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
    var responseJson = jsonDecodeCustom(responseString);
    print('Risposta JSON: $responseJson');
    if (response.statusCode == 200) {
      if (responseJson["access_token"] != null) {
        return responseJson["access_token"];
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
    final responseJson = jsonDecodeCustom(responseString);
    print("generate");
    print(responseJson);
    if (response.statusCode == 200 && responseJson["address"] != null) {
      return responseJson["address"] + "@duck.com";
    }
  } catch (e) {
    print('Error: $e');
  }
  return "null";
}
