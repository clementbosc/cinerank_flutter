import 'dart:collection';

import 'package:http/http.dart' as http;
import 'dart:convert';

class Movie {
  final String name;
  final int allocineId;
  final int imdbId;
  final String gaumontId;
  final int tmdbId;
  final String backdropPath;
  final String posterPath;
  final double score;
  Map<String, double> rates;

  Movie(
      {this.name,
      this.allocineId,
      this.imdbId,
      this.gaumontId,
      this.tmdbId,
      this.backdropPath,
      this.posterPath,
      this.score,
      this.rates});

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
        name: json['name'],
        allocineId: json['allocine_id'],
        imdbId: json['imdb_id'],
        gaumontId: json['gaumont_id'],
        tmdbId: json['tmdb_id'],
        backdropPath: json['backdrop_path'],
        posterPath: json['poster_path'],
        score: json['score'],
        rates: new HashMap<String, double>.from(json['rates'])
    );
  }
}

Future<List<Movie>> fetchMovies({cinema: "cinema-gaumont-wilson"}) async {
  final response =
      await http.get('https://cinerank-cloud.appspot.com/cinemas/'+cinema+'/rates');
  if (response.statusCode == 200) {
    List<Movie> movies = new List();
    // If the call to the server was successful, parse the JSON.
    for (var movie in json.decode(response.body)['movies']) {
      movies.add(Movie.fromJson(movie));
    }
    return movies;
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load movies');
  }
}
