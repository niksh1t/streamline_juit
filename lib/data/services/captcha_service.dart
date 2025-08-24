// services/captcha_service.dart
/*
import 'dart:convert';
import 'package:http/http.dart' as http;

class CaptchaService {
  final String _baseUrl = "https://webportal.juit.ac.in:6011/StudentPortalAPI";
  final Map<String, String> _headers = {
*/
 //   "accept": "application/json, text/plain, */*",
/*
    "authorization": "Bearer",
    "content-type": "application/json",
    "localname": "tHj7qqK+nhwJDFyvJqPWmGMNo86qnsfkWnXMOSRoiZw=",
  };

  // Fetches a new captcha image and its hidden value
  Future<Map<String, dynamic>> getCaptcha() async {
    final uri = Uri.parse("$_baseUrl/token/getcaptcha");
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load captcha from API');
    }
  }

  // You can add the verification logic here in the future
  // Future<Map<String, dynamic>> verifyCaptcha(String userInput, String hiddenValue) async {
  //   // Your POST request logic will go here
  // }
  }
*/