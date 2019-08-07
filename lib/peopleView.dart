import 'package:flutter/material.dart';

import 'main.dart';

import 'models/people.dart';
import 'models/tmdbMovie.dart';
import 'movieView.dart';

class PeopleView extends StatelessWidget {
  final People people;

  const PeopleView({Key key, this.people}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(this.people.name),
        ),
        body: _body());
  }

  _body() {
    return FutureBuilder<People>(
        future: fetchPeople(this.people.id, fetchCredits: true),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            People people_full = snapshot.data;
            return Container(
                //padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    colorFilter: new ColorFilter.mode(
                        Colors.black.withOpacity(0.5), BlendMode.srcATop),
                    image: NetworkImage(people_full.backdropPath != null
                        ? "https://image.tmdb.org/t/p/w1280" +
                            people_full.backdropPath
                        : defaultBackground),
                    fit: BoxFit.cover,
                  ),
                ),
                child: _mainContent(people_full));
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}",
                style: TextStyle(color: Colors.black87));
          }

          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }

  Widget _mainContent(People people_full) {
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
                          people.profile_path != null
                              ? "https://image.tmdb.org/t/p/w500" +
                                  people.profile_path
                              : defaultPoster,
                          width: 200),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(15),
                    child: Text(people.name,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 35,
                            fontWeight: FontWeight.bold)),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 15, right: 15, bottom: 15),
                        child: Text(people_full.biography,
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _displayMovies(people_full, context)
                        ],
                      )
                    ],
                  )
                ],
              )));
    });
  }
}

Widget _displayMovies(People people, BuildContext context) {
  //people.casted_in.sort((a, b) => a.popularity.compareTo(b.popularity));
  return Container(
      height: 235,
      margin: EdgeInsets.only(top: 5, bottom: 15),
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: people.casted_in.length,
          itemBuilder: (context, index) {
            TmdbMovie movie = people.casted_in[index];
            return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MovieView(
                              backdropPath: movie.backdropPath,
                              posterPath: movie.posterPath,
                              name: movie.title,
                              tmdbMovieId: movie.id,
                            )),
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
                                    movie.posterPath != null
                                        ? "https://image.tmdb.org/t/p/w500" +
                                            movie.posterPath
                                        : defaultPoster,
                                    fit: BoxFit.cover)),
                            //),
                            Padding(
                              padding: EdgeInsets.all(6),
                              child: Text(movie.title,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ))));
          }));
}
