import 'dart:convert';
import 'package:http/http.dart' as http;

import 'tmdbMovie.dart';



class People {
  final DateTime birthday;
  final String known_for_department;
  final DateTime deathday;
  final int id;
  final String name;
  final List<String> also_known_as;
  final int gender;
  final String biography;
  final double popularity;
  final String place_of_birth;
  final String profile_path;
  final bool adult;
  final String imdb_id;
  final String homepage;
  final String movies;
  final String backdrop;
  String backdropPath;
  List<TmdbMovie> casted_in;
  List<TmdbMovie> crewed_in;

  People(
      {this.birthday,
      this.known_for_department,
      this.deathday,
      this.id,
      this.name,
      this.also_known_as,
      this.gender,
      this.biography,
      this.popularity,
      this.place_of_birth,
      this.profile_path,
      this.adult,
      this.imdb_id,
      this.homepage,
      this.movies,
      this.backdrop,

        this.backdropPath}){
    this.casted_in = new List<TmdbMovie>();
    this.crewed_in = new List<TmdbMovie>();
  }

  factory People.fromJson(Map<String, dynamic> json) {
    return People(
        birthday: json['birthday'] != null ? DateTime.parse(json['birthday']): null,
        known_for_department: json['known_for_department'],
        deathday: json['deathday'] != null ? DateTime.parse(json['deathday']) : null,
        id: json['id'],
        name: json['name'],
        also_known_as: json['also_known_as'] != null ? new List<String>.from(json['also_known_as']) : null,
        gender: json['gender'],
        biography: json['biography'],
        popularity: json['popularity'],
        place_of_birth: json['place_of_birth'],
        profile_path: json['profile_path'],
        adult: json['adult'],
        imdb_id: json['imdb_id'],
        homepage: json['homepage'],
        movies: json['movies'],
        backdrop: json['backdrop']);
  }
}

Future<People> fetchPeople(int peopleId, {bool fetchCredits: false}) async {
  People people;
  final people_request_url = 'https://api.themoviedb.org/3/person/' +
      peopleId.toString() +
      '?api_key=' +
      tmdb_api_key;
  var response = await http.get(people_request_url);
  if (response.statusCode == 200) {
    people = People.fromJson(json.decode(response.body));
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load people');
  }

  if (fetchCredits){
    final people_request_url = 'https://api.themoviedb.org/3/person/' +
        people.id.toString() +
        '/movie_credits?api_key=' +
        tmdb_api_key;
    var response = await http.get(people_request_url);
    if (response.statusCode == 200) {
      final res_json = json.decode(response.body);
      for (var cast in res_json['cast']){
        people.casted_in.add(TmdbMovie.fromJson(cast));
      }
      for (var crew in res_json['crew']){
        people.crewed_in.add(TmdbMovie.fromJson(crew));
      }
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load people');
    }
    if (people.casted_in.isNotEmpty){
      people.backdropPath = people.casted_in.first.backdropPath;
    }
  }

  return people;
}

