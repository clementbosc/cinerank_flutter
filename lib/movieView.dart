import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'bookingView.dart';
import 'main.dart';

import 'models/cinema.dart';
import 'models/movie.dart';
import 'models/people.dart';
import 'models/tmdbMovie.dart';
import 'peopleView.dart';

class MovieView extends StatelessWidget {
  int tmdbMovieId;
  String name;
  String backdropPath;
  String posterPath;
  Movie movie;
  TmdbMovie tmdbMovie;
  String preferedCinema;

  MovieView(
      {Key key,
      this.tmdbMovieId,
      this.name,
      this.backdropPath,
      this.posterPath,
      this.movie,
      this.tmdbMovie,
      this.preferedCinema}) {
    if ((this.backdropPath == null || this.posterPath == null) &&
        this.movie != null) {
      this.backdropPath = this.movie.backdropPath;
      this.posterPath = this.movie.posterPath;
    }
    if (this.name == null && this.movie != null) {
      this.name = this.movie.name;
    }
    if (this.tmdbMovieId == null && this.movie != null) {
      this.tmdbMovieId = this.movie.tmdbId;
    }
    //if (this.tmdbMovieId == null ||
    //    this.name == null ||
    //    this.backdropPath == null ||
    //    this.posterPath == null)
    //  throw new Exception("null required fields movieView !");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(this.name),
        ),
        body: Container(
            //padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              image: DecorationImage(
                colorFilter: new ColorFilter.mode(
                    Colors.black.withOpacity(0.5), BlendMode.srcATop),
                image: NetworkImage(this.backdropPath != null
                    ? "https://image.tmdb.org/t/p/w1280" + this.backdropPath
                    : defaultBackground),
                fit: BoxFit.cover,
              ),
            ),
            child: _mainContent()));
  }

  Widget _mainContent() {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return SingleChildScrollView(
          child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Image.network(
                          this.posterPath != null
                              ? "https://image.tmdb.org/t/p/w500" +
                                  this.posterPath
                              : defaultPoster,
                          width: 200),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 5, right: 15, left: 15),
                    child: Text(this.name,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 35,
                            fontWeight: FontWeight.bold)),
                  ),
                  (this.tmdbMovie == null
                      ? (FutureBuilder<TmdbMovie>(
                          future: fetchTmdbMovie(this.tmdbMovieId),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return _movieInfos(snapshot.data, context,
                                  this.movie, this.preferedCinema);
                            } else if (snapshot.hasError) {
                              return Text("${snapshot.error}",
                                  style: TextStyle(color: Colors.white));
                            }
                            return Center(
                                child: CircularProgressIndicator(
                                    backgroundColor: Colors.white));
                          },
                        ))
                      : _movieInfos(this.tmdbMovie, context, this.movie,
                          this.preferedCinema))
                ],
              )));
    });
  }
}

Widget _movieInfos(TmdbMovie tmdbMovie, BuildContext context, Movie movie,
    String preferedCinema) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.only(left: 15.0, right: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                  tmdbMovie.getFrenchReleaseDate() != null
                      ? ("Sorti le " + tmdbMovie.getFrenchReleaseDate())
                      : "Date de sortie inconnue",
                  style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                      fontSize: 20)),
            ),
            Text(tmdbMovie.overview,
                style: TextStyle(color: Colors.white, fontSize: 18))
          ],
        ),
      ),
      (movie == null || preferedCinema == null
          ? Container()
          : (FutureBuilder<List<dynamic>>(
              future: fetchMovieShowtime(preferedCinema, movie.gaumontId),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return FutureBuilder<Cinema>(
                    future: fetchCinema(preferedCinema),
                    builder: (context, cine_snapshot) {
                      if (cine_snapshot.hasData) {
                        return _displaySeances("Séances au "+cine_snapshot.data.name, snapshot.data, context);
                      }
                      return _displaySeances("Séances", snapshot.data, context);
                    },
                  );

                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}",
                      style: TextStyle(color: Colors.white));
                }
                return Center(
                    child: CircularProgressIndicator(
                        backgroundColor: Colors.white));
              },
            ))),
      Padding(
          padding: EdgeInsets.only(top: 20, left: 15, right: 15),
          child: Text("Acteurs",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold))),
      _displayPeoples(tmdbMovie, context)
    ],
  );
}

_displaySeances(String title, List<dynamic> seances, BuildContext context) {
  seances.sort((a, b) => a['time'].compareTo(b['time']));
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Padding(
          padding: EdgeInsets.only(top: 20, left: 15, right: 15),
          child: Text(title,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold))),
      Container(
          height: 73,
          margin: EdgeInsets.only(top: 5, bottom: 10),
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: seances.length,
              itemBuilder: (context, index) {
                dynamic seance = seances[index];
                return GestureDetector(
                    onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    BookingView(seance['refCmd'])),
                          );
                        },
                    child: Card(
                        child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Text(new DateFormat('dd/MM H:m', 'fr_FR')
                                .format(DateTime.parse(seance['time']))),
                          ),
                          Text(
                            (seance['version'].toString()+' '+(seance['tags'] as List).where((f) => f == 'dolby' || f == '3d').toList().join(' ')).toUpperCase(),
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )));
              }))
    ],
  );
}

_displayPeoples(TmdbMovie movie, BuildContext context) {
  return Container(
      height: 235,
      margin: EdgeInsets.only(top: 5, bottom: 15),
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: movie.cast.length,
          itemBuilder: (context, index) {
            People people = movie.cast[index];
            return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PeopleView(people: people)),
                  );
                },
                child: Card(
                    elevation: 5,
                    child: Container(
                        width: 130,
                        child: Column(
                          children: <Widget>[
                            //Expanded(
                            // child:
                            ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  topRight: Radius.circular(4),
                                ),
                                child: Image.network(
                                    people.profile_path != null
                                        ? "https://image.tmdb.org/t/p/w500" +
                                            people.profile_path
                                        : defaultPoster,
                                    fit: BoxFit.cover)),
                            //),
                            Padding(
                              padding: EdgeInsets.all(6),
                              child: Text(people.name,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ))));
          }));
}
