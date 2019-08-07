import 'dart:collection';

import 'package:http/http.dart' as http;
import 'dart:convert';

class Cinema {
  final String id;
  final String name;
  final String ville;

  Cinema(
      {this.id,
      this.name,
      this.ville,});

  factory Cinema.fromJson(Map<String, dynamic> json) {
    return Cinema(
        name: json['name'],
        id: json['id'],
        ville: json['ville'],
    );
  }
}

Future<List<Cinema>> fetchCinemas() async {
  final response =
      await http.get('https://cinerank-cloud.appspot.com/cinemas');
  if (response.statusCode == 200) {
    List<Cinema> cinemas = new List();
    // If the call to the server was successful, parse the JSON.
    for (var cinema in json.decode(response.body)) {
      cinemas.add(Cinema.fromJson(cinema));
    }
    return cinemas;
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load cinemas');
  }
}
