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
  List<dynamic> seances;

  Movie(
      {this.name,
      this.allocineId,
      this.imdbId,
      this.gaumontId,
      this.tmdbId,
      this.backdropPath,
      this.posterPath,
      this.score,
      this.rates}){
    this.seances = new List<dynamic>();
  }

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

Future<List<Movie>> fetchMovies({cinema: "cinema-gaumont-wilson", with_seances: false}) async {
  var response =
      await http.get('https://cinerank-cloud.appspot.com/cinemas/'+cinema+'/rates');
  if (response.statusCode == 200) {
    List<Movie> movies = new List();
    // If the call to the server was successful, parse the JSON.
    for (var movie in json.decode(response.body)['movies']) {
      Movie m = Movie.fromJson(movie);
      if (with_seances){
        response = await http.get('https://cinerank-cloud.appspot.com/cinemas/'+cinema+'/movies/'+m.gaumontId+'/showtimes');
        if (response.statusCode == 200) {
          m.seances = new List<dynamic>.from(json.decode(response.body));
        }else {
          // If that call was not successful, throw an error.
          throw Exception('Failed to load movie showtimes for'+m.gaumontId);
        }
      }

      movies.add(m);
    }
    return movies;
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load movies');
  }
}

Future<List<dynamic>> fetchMovieShowtime(String cinema, String film_id) async {
  var response =
  await await http.get('https://cinerank-cloud.appspot.com/cinemas/'+cinema+'/movies/'+film_id+'/showtimes');
  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON.
    return new List<dynamic>.from(json.decode(response.body) as List);
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load movie showtimes for '+film_id);
  }
}
