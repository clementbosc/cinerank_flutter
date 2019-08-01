import 'package:flutter/material.dart';

import 'main.dart';
import 'models/movie.dart';
import 'movieView.dart';

class Home extends StatelessWidget {
  final Future<List<Movie>> movies;

  Home({Key key, this.movies}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cinerank',
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'Cinerank 🎬',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: primaryColor,
        ),
        body: Container(
          child: FutureBuilder<List<Movie>>(
            future: movies,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      Movie movie = snapshot.data[index];
                      return _buildMovieRow(movie, context);
                    });
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}",
                    style: TextStyle(color: Colors.black87));
              }

              // By default, show a loading spinner.
              return Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ),
      ),
    );
  }
}

StatelessWidget _buildMovieRow(Movie movie, BuildContext context) {
  return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MovieView(movie: movie)),
        );
      },
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          image: DecorationImage(
            colorFilter: new ColorFilter.mode(
                Colors.black.withOpacity(0.5), BlendMode.srcATop),
            image: NetworkImage(movie.backdropPath != null
                ? "https://image.tmdb.org/t/p/w500" + movie.backdropPath
                : defaultBackground),
            fit: BoxFit.cover,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Image.network(
                movie.posterPath != null
                    ? "https://image.tmdb.org/t/p/w500" + movie.posterPath
                    : defaultPoster,
                width: 100),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 15, top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(bottom: 5),
                      child: Text(
                        movie.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Text(
                        movie.score.toString(),
                        style: TextStyle(color: Colors.white, fontSize: 25),
                      ),
                    ),
                    getSitesRateWidgets(movie)
                  ],
                ),
              ),
            )
          ],
        ),
      ));
}

Widget getSitesRateWidgets(Movie movie) {
  List<Widget> list = new List<Widget>();
  for (var entry in movie.rates.entries) {
    list.add(Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: new Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Image.asset(
              getImageFromSite(entry.key),
            ),
          ),
          new Text(
            entry.value.toString(),
            style: TextStyle(color: Colors.white, fontSize: 18),
          )
        ],
      ),
    ));
  }
  return new Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: list);
}

String getImageFromSite(String site) {
  if (site == 'allocine')
    return 'assets/allocine_logo.png';
  else if (site == 'imdb') return 'assets/imdb_logo.png';
  throw new Exception("Unkown movie site");
}
