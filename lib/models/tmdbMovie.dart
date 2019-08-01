import 'dart:collection';
import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;

import 'people.dart';

const tmdb_api_key = "32c2115b63d2b870f0f58d85da6a8183";
const tmdb_language = "fr-FR";

class TmdbMovie {
  final int id;
  final String backdropPath;
  final String posterPath;
  final String overview;
  final String title;
  final String originalTitle;
  final String originalLanguage;
  final int budget;
  final String homepage;
  final double popularity;
  final DateTime defaultReleaseDate;
  final int revenue;
  final int runtime;
  final String status;
  final String tagline;
  final bool video;
  final double vote_average;
  final int vote_count;
  List<People> cast;
  List<People> crew;
  Map<String, DateTime> release_dates;

  TmdbMovie({
    this.id,
    this.backdropPath,
    this.posterPath,
    this.overview,
    this.title,
    this.originalTitle,
    this.originalLanguage,
    this.cast,
    this.crew,
    this.budget,
    this.homepage,
    this.popularity,
    this.defaultReleaseDate,
    this.revenue,
    this.runtime,
    this.status,
    this.tagline,
    this.video,
    this.vote_average,
    this.vote_count,
  }) {
    this.crew = new List();
    this.cast = new List();
    this.release_dates = new HashMap();
  }

  factory TmdbMovie.fromJson(Map<String, dynamic> json) {
    return TmdbMovie(
      backdropPath: json['backdrop_path'],
      title: json['title'],
      overview: json['overview'],
      posterPath: json['poster_path'],
      id: json['id'],
      originalLanguage: json['original_language'],
      originalTitle: json['original_title'],
      budget: json['budget'],
      homepage: json['homepage'],
      popularity: json['popularity'] != null ? json['popularity'].toDouble() : null,
      //defaultReleaseDate: json['release_date'] != null
      //    ? DateTime.parse(json['release_date'])
      //    : null,
      revenue: json['revenue'],
      runtime: json['runtime'],
      status: json['status'],
      tagline: json['tagline'],
      video: json['video'],
      vote_average: json['vote_average'] != null ? json['vote_average'].toDouble() : null,
      vote_count: json['vote_count'] != null ? json['vote_count'] : null,
    );
  }

  String getFrenchReleaseDate() {
    return release_dates['FR'] != null
        ? new DateFormat('dd MMM yyyy', 'fr_FR').format(release_dates['FR'])
        : null;
  }
}

Future<TmdbMovie> fetchTmdbMovie(int movieId) async {
  final movie_request_url = 'https://api.themoviedb.org/3/movie/' +
      movieId.toString() +
      '?api_key=' +
      tmdb_api_key +
      '&language=' +
      tmdb_language;
  var response = await http.get(movie_request_url);
  var tmdbMovie = null;
  if (response.statusCode == 200) {
    tmdbMovie = TmdbMovie.fromJson(json.decode(response.body));
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load movie');
  }

  final credits_request_url = 'https://api.themoviedb.org/3/movie/' +
      movieId.toString() +
      '/credits?api_key=' +
      tmdb_api_key +
      '&language=' +
      tmdb_language;
  response = await http.get(credits_request_url);
  if (response.statusCode == 200) {
    var peoples_json = json.decode(response.body);
    for (final c in peoples_json['cast']) {
      tmdbMovie.cast.add(People.fromJson(c));
    }
    for (final c in peoples_json['crew']) {
      tmdbMovie.crew.add(People.fromJson(c));
    }
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load movie credits');
  }

  final release_dates_request_url = 'https://api.themoviedb.org/3/movie/' +
      movieId.toString() +
      '/release_dates?api_key=' +
      tmdb_api_key;
  response = await http.get(release_dates_request_url);
  if (response.statusCode == 200) {
    var release_dates_json = json.decode(response.body)['results'];
    //print(release_dates_json);
    for (var rd in release_dates_json) {
      for (var sub_rd in rd['release_dates']) {
        // print(rd['iso_3166_1']+(sub_rd['iso_639_1'] != "" ? "-"+sub_rd['iso_639_1'] : ""));
        // print(sub_rd['release_date']);
        tmdbMovie.release_dates.putIfAbsent(
            rd['iso_3166_1'] +
                (sub_rd['iso_639_1'] != "" ? "-" + sub_rd['iso_639_1'] : ""),
            () => DateTime.parse(sub_rd['release_date'].toString()));
      }
      //print(rd['iso_3166_1']+' - '+rd['release_dates']['release_date']);
      //tmdbMovie.release_dates.putIfAbsent(rd['iso_3166_1'], rd['release_dates']['release_date']);
    }
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load movie release dates');
  }

  return tmdbMovie;
}
