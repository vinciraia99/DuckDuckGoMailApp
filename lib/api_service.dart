import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const headers = {
  'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:128.0) Gecko/20100101 Firefox/128.0',
};

const headers2={
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, GET, OPTIONS, PUT, DELETE, HEAD"
};

const hostDuckDuckGO = "quack.duckduckgo.com";

String getProxyUrl(String targetUrl) {
  if (kIsWeb) {
    return  Uri.https("api.allorigins.win","get",{'url':targetUrl}).toString();
  }
  return targetUrl;
}

Future<bool> loginRequest(String username) async {
  var url = Uri.https(hostDuckDuckGO, '/api/auth/loginlink', {'user': username});
  print(url.toString());
  var requestUrl = getProxyUrl(url.toString());
  print(requestUrl);
  var request = http.Request('GET', Uri.parse(requestUrl));

  if (!kIsWeb) {
    request.headers.addAll(headers);
  }
  request.headers.addAll(headers2);

  http.StreamedResponse response = await request.send();
  print(response.statusCode);
  if (response.statusCode == 200) {
    return true;
  }
  return false;
}

Future<String> login(String username, String otp) async {
  var url = Uri.https(hostDuckDuckGO, '/api/auth/login', {'user': username, 'otp': otp});
  print(url.toString());
  var requestUrl = getProxyUrl(url.toString());
  var request = http.Request('GET', Uri.parse(requestUrl));

  if (!kIsWeb) {
    request.headers.addAll(headers);
  }

  http.StreamedResponse response = await request.send();
  final responseString = await response.stream.bytesToString();
  final responseJson = jsonDecode(responseString);
  print(responseJson);
  print(response.statusCode);
  if (response.statusCode == 200) {
    if(responseJson["status"] =="authenticated"){
      return responseJson["token"];
    }
  } else {
    if (kDebugMode) {
      print(responseJson["error"]);
    }
  }
  return "";
}

Future<String> generate(String username, String token) async {
  var authorization = {
    'Authorization': 'Bearer $token',
  };
  var request = http.Request(
      'POST', Uri.parse('https://quack.duckduckgo.com/api/email/addresses'));

  request.headers.addAll(headers);
  request.headers.addAll(authorization);

  http.StreamedResponse response = await request.send();
  final responseString = await response.stream.bytesToString();
  final responseJson = jsonDecode(responseString);

  if (kDebugMode) {
    print("generate");
  }

  if (response.statusCode == 200 && responseJson["address"] != null) {
    if (kDebugMode) {
      print(responseJson["address"]);
    }
    return responseJson["address"] + "@duck.com";
  } else {
    return "null";
  }
}
