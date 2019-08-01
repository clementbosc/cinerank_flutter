


import 'package:flutter/material.dart';

import '../main.dart';
import '../peopleView.dart';

Widget carousel(List<dynamic> items, BuildContext context) {
  return Container(
      height: 235,
      margin: EdgeInsets.only(top: 5, bottom: 15),
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          itemBuilder: (context, index) {
            dynamic item = items[index];
            return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PeopleView(people: item)),
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
                                    item.profile_path != null
                                        ? "https://image.tmdb.org/t/p/w500" +
                                        item.profile_path
                                        : defaultPoster,
                                    fit: BoxFit.cover)),
                            //),
                            Padding(
                              padding: EdgeInsets.all(6),
                              child: Text(item.name,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ))));
          }));
}
