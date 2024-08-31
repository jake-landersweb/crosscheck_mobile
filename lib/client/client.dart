import 'package:http/http.dart' as http;
import 'dart:convert';
import 'env.dart';

class Client {
  // base url that entire app will run off
  static const host = HOST;

  // http client, needed for all requests
  final http.Client client;

  // init the class and make sure it has an inherited client
  const Client({
    required this.client,
  });

  // generic fetch function
  Future<dynamic> fetch(String path) async {
    // start the response
    final response = await client.get(Uri.parse("$host$path"));
    // check for basic network errors
    if (response.statusCode != 200) {
      print(response);
      throw Exception('There was an error fetching: ${response.body}');
    }

    // return the decoded information
    return jsonDecode(response.body);
  }

  // more generic fetch function
  Future<http.Response> genericFetch(String uri) async {
    // start the response
    return await client.get(Uri.parse(uri));
  }

  Future<dynamic> post(
      String path, Map<String, String> headers, dynamic body) async {
    final http.Response response = await http.post(
      Uri.parse("$host$path"),
      body: body,
      headers: headers,
    );

    return jsonDecode(response.body);
  }

  Future<http.Response> genericPost(
      String uri, Map<String, String> headers, dynamic body) async {
    return await http.post(
      Uri.parse(uri),
      body: body,
      headers: headers,
    );
  }

  Future<dynamic> put(
    String path,
    Map<String, String> headers,
    dynamic body,
  ) async {
    final http.Response response = await http.put(
      Uri.parse("$host$path"),
      body: body,
      headers: headers,
    );

    return jsonDecode(response.body);
  }

  // generic fetch function
  Future<dynamic> delete(String path) async {
    // start the response
    final response = await client.delete(Uri.parse("$host$path"));
    // check for basic network errors
    if (response.statusCode != 200) {
      throw Exception('There was an error fetching: ${response.body}');
    }

    // return the decoded information
    return jsonDecode(response.body);
  }
}
