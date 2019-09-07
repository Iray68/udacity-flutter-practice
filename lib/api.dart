import 'dart:async';
import 'dart:convert' show json, utf8;
import 'dart:io';

class Api {
  final router = {
    'name': 'Currency',
    'route': 'currency',
  };
  final HttpClient _httpClient = HttpClient();
  final String _url = 'flutter.udacity.com';

  Future<List> getUnits(String category) async {
    final uri = Uri.https(_url, '/$category');
    final jsonResponse = await _fetch(uri);
    if (jsonResponse == null || jsonResponse['units'] == null) {
      print('Error');
      return null;
    }
    return jsonResponse['units'];
  }

  Future<double> convert(
      String category, String from, String to, String amount) async {
    final uri = Uri.https(_url, '/$category/convert',
        {'from': from, 'to': to, 'amount': amount});
    print(uri);
    final jsonResponse = await _fetch(uri);

    if (jsonResponse == null || jsonResponse['conversion'] == null) {
      print('Error');
      return null;
    }

    return jsonResponse['conversion'].toDouble();
  }

  Future<Map<String, dynamic>> _fetch(Uri uri) async {
    try {
      HttpClientRequest request = await _httpClient.getUrl(uri);

      HttpClientResponse response = await request.close();

      final responseBody = await response.transform(utf8.decoder).join();

      return json.decode(responseBody);

    } on Exception catch (e) {
      print(e.toString());
      return null;
    }
  }
}