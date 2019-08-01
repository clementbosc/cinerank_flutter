// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'home.dart';
import 'models/movie.dart';

const primaryColor = Colors.black87;
const defaultBackground =
    "https://www.solidbackgrounds.com/images/1920x1080/1920x1080-yellow-solid-color-background.jpg";
const defaultPoster =
    "https://images-na.ssl-images-amazon.com/images/I/A1t8xCe9jwL._SL1500_.jpg";



void main(){
  initializeDateFormatting();
  return runApp(Home(movies: fetchMovies()));
}
