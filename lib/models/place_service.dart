import 'dart:convert';
import 'package:http/http.dart';

class Suggestion {
  final String name;

  Suggestion(this.name);

  @override
  String toString() {
    return 'Suggestion(name: $name)';
  }
}

class PlaceApiProvider {
  final client = Client();

  PlaceApiProvider();


  Future<List<Suggestion>> fetchSuggestions(String input, String lang) async {
    final String request =
        'https://wft-geo-db.p.rapidapi.com/v1/geo/cities?limit=5&offset=0&namePrefix=$input';
    var response = await get(Uri.encodeFull(request), headers: {
      'x-rapidapi-host': 'wft-geo-db.p.rapidapi.com',
      'x-rapidapi-key': 'dfcf1ca724mshc9512b1c33ce06ep1f1b2djsn0ea4fcdd8bc1',
    });

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      List<dynamic> properties = result['data'];
      String name = properties.first['name'].toString();
      return result['data']
          .map<Suggestion>((p) => Suggestion(p['name']))
          .toList();
    } else {
      print('getCityDB() Request failed with status: ${response.statusCode}.');
    }
  }
}
