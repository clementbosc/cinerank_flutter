import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';


class BookingView extends StatelessWidget {
  String url;

  BookingView(this.url);

  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      url: this.url,
      appBar: new AppBar(
        title: new Text("Réservation"),
      ),
      userAgent: 'cinerank',
    );
  }

}