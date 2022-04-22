import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:driver_app/Models/allUsers.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'Models/drivers.dart';

String  mapKey ="AIzaSyAWvGy57byDiBmBC90b4ZxU72GWCioMwss";
User firebaseUser = firebaseUser;
 User? currentfirebaseUser = currentfirebaseUser;

Users userCurrentInfo = Users() ;
StreamSubscription<Position> homeTabPageStreamSubscription = Geolocator.getPositionStream().listen((Position position) {});
final assetsAudioPlayer = AssetsAudioPlayer();
StreamSubscription<Position> rideStreamSubscription = Geolocator.getPositionStream().listen((Position position) {});



late Position currentPosition;

Drivers driversInformation = Drivers();

String title="";
double starCounter=0.0;

String rideType="";
 double currency =0.0;




