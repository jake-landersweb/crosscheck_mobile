import 'package:http/http.dart' as http;
import 'dart:convert';

class Client {
  // base url that entire app will run off
  static const host = 'w9o1i3foe2.execute-api.us-west-2.amazonaws.com';

  // http client, needed for all requests
  final http.Client client;

  // init the class and make sure it has an inherited client
  const Client({
    required this.client,
  });

  // generic fetch function
  Future<dynamic> fetch(String path) async {
    // start the response
    final response =
        await client.get(Uri(scheme: 'https', host: host, path: '/api/$path'));
    // check for basic network errors
    if (response.statusCode != 200) {
      throw Exception('There was an error fetching: ${response.body}');
    }

    // return the decoded information
    return jsonDecode(response.body);
  }

  // more generic fetch function
  Future<dynamic> genericFetch(String scheme, String phost, String path) async {
    // start the response
    final response =
        await client.get(Uri(scheme: scheme, host: phost, path: path));

    // check for basic network errors
    if (response.statusCode != 200) {
      throw Exception('There was an error fetching: ${response.toString()}');
    }

    // return the decoded information
    return jsonDecode(response.body);
  }

  Future<dynamic> post(
      String path, Map<String, String> headers, dynamic body) async {
    final http.Response response = await http.post(
        Uri(scheme: 'https', host: host, path: '/api/$path'),
        body: body,
        headers: headers);

    return jsonDecode(response.body);
  }

  Future<dynamic> put(
      String path, Map<String, String> headers, dynamic body) async {
    final http.Response response = await http.put(
      Uri(scheme: 'https', host: host, path: '/api/$path'),
      body: body,
      headers: headers,
    );

    return jsonDecode(response.body);
  }
}
