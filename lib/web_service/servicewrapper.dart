import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

import 'package:sms_demo/globles.dart';
import 'package:sms_demo/models/model_login.dart';

class Servicewrapper {
  String token = usr?.accessToken ?? '';
  var baseurl = "http://65.109.182.56:8082/";

  final printMinPriority = 5;
  printPriority(Object? object, int priority) {
    if (printMinPriority <= priority) print(object);
  }

  void showErrorMsg(String error) {
    final SnackBar snackBar = SnackBar(
        margin: EdgeInsets.only(bottom: 20),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        content: Text(
          error,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ));
    snackbarKey.currentState?.showSnackBar(snackBar);
  }

  var language = 1;
  dynamic _response(http.Response response) {
    if (response.statusCode != 200) {
      print('response.statusCode != 200');
      print(response.body);
      var responseJson = json.decode(response.body.toString());
      final Map<String, dynamic> parsed = responseJson;
      if (parsed['message'] != null) showErrorMsg(parsed['message']);
    }
    switch (response.statusCode) {
      case 200:
        var responseJson = json.decode(response.body.toString());
        printPriority(responseJson, 1);
        return responseJson;
      case 400:
        throw Exception(response.body.toString());
      case 401:
        throw Exception(response.body.toString());
      case 403:
        throw Exception(response.body.toString());
      case 500:
        throw Exception(response.body.toString());
      default:
    }
  }

  //signUp
  signUp(username, email, password) async {
    var responseJson;
    var url = baseurl + "api/auth/signup";
    final body = {
      'username': username,
      'email': email,
      'password': password,
      'role': ['user']
    };
    print("signup" + url + "---" + json.encode(body));
    final response = await http.post(Uri.parse(url),
        headers: {
          'Content-type': 'application/json;charset=UTF-8',
          'Accept': 'application/json',
        },
        body: json.encode(body));
    try {
      responseJson = _response(response);
      print("responseJson" + response.toString());
    } catch (e) {
      print('error caught signup : $e');
      return responseJson;
    }
    return responseJson;
  }

  //LogIn
  logIn(username, password) async {
    var responseJson;
    var url = baseurl + "api/auth/signin";
    final body = {'username': username, 'password': password};
    printPriority('*****logIn*****', 5);
    printPriority(body, 5);
    final response = await http.post(Uri.parse(url),
        headers: {
          'Content-type': 'application/json;charset=UTF-8',
          'Accept': 'application/json',
        },
        body: json.encode(body));
    try {
      // printPriority(response.body, 5);
      responseJson = _response(response);
    } catch (e) {
      print('error caught Login : $e');
      return responseJson;
    }
    return responseJson;
  }

  updateTaskUser(task_id) async {
    var responseJson;
    var url = baseurl + "api/sms_task_user/update";
    final body = {'task_id': task_id};
    printPriority('*****logIn*****', 5);
    printPriority(body, 5);
    final response = await http.post(Uri.parse(url),
        headers: {
          'Content-type': 'application/json;charset=UTF-8',
          'Accept': 'application/json',
          'x-access-token': token
        },
        body: json.encode(body));
    try {
      //printPriority(response.body, 5);
      responseJson = _response(response);
    } catch (e) {
      print('error caught Login : $e');
      return responseJson;
    }
    return responseJson;
  }

  getSmsTask() async {
    var responseJson;
    var url = baseurl + "api/sms_task/find";
    final body = {};
    printPriority("sms task" + url + "---" + json.encode(body), 1);
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-type': 'application/json;charset=UTF-8',
        'Accept': 'application/json',
        'x-access-token': token
      },
    );

    printPriority("sms_task" + response.body, 1);
    try {
      responseJson = _response(response);
    } catch (e) {
      print('error caught sms_task : $e');
      return responseJson;
    }
    return responseJson;
  }

  userDetails() async {
    var responseJson;
    var url = baseurl + "api/user/details";
    final body = {};
    printPriority("user info" + url + "---" + json.encode(body), 1);
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-type': 'application/json;charset=UTF-8',
        'Accept': 'application/json',
        'x-access-token': token
      },
    );

    printPriority("user_info_json" + response.body, 1);
    try {
      responseJson = _response(response);
    } catch (e) {
      print('error caught userinfo : $e');
      return responseJson;
    }
    return responseJson;
  }
}
