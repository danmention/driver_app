import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:driver_app/Models/rideDetails.dart';
import 'package:driver_app/Notifications/notificationDialog.dart';
import 'package:driver_app/configMaps.dart';
import 'package:driver_app/main.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;

import 'package:google_maps_flutter/google_maps_flutter.dart';

class PushNotificationService
{
 // final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;


  Future initialize(context) async
  {

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;



     retrieveRideRequestInfo(getRideRequestId(message.data), context);

      // if (notification != null && android != null) {
      //   flutterLocalNotificationsPlugin.show(
      //       notification.hashCode,
      //       notification.title,
      //       notification.body,
      //       NotificationDetails(
      //         android: AndroidNotificationDetails(
      //           channel.id,
      //           channel.name,
      //           channel.description,
      //           color: Colors.blue,
      //           playSound: true,
      //           icon: '@mipmap/ic_launcher',
      //         ),
      //       ));
      // }
    });


    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!  ${getRideRequestId(message.data)}');
      print('Message data: ${message.data}');

      retrieveRideRequestInfo(getRideRequestId(message.data), context);


      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      // if (notification != null && android != null) {
      //   showDialog(
      //       context: context,
      //       builder: (_) {
      //         return AlertDialog(
      //           title: Text(notification.title!),
      //           content: SingleChildScrollView(
      //             child: Column(
      //               crossAxisAlignment: CrossAxisAlignment.start,
      //               children: [Text(notification.body!)],
      //             ),
      //           ),
      //         );
      //       });
      // }
    });


    // firebaseMessaging.configure(
    //   onMessage: (Map<String, dynamic> message) async {
    //    // retrieveRideRequestInfo(getRideRequestId(message), context);
    //   },
    //   onLaunch: (Map<String, dynamic> message) async {
    //     print(" on launc");
    //    // retrieveRideRequestInfo(getRideRequestId(message), context);
    //   },
    //   onResume: (Map<String, dynamic> message) async {
    //    // retrieveRideRequestInfo(getRideRequestId(message), context);
    //   },
    // );
  }

  Future<String?> getToken() async
  {
    String? token = await firebaseMessaging.getToken();
    print("This is token :: ");
    print(token);
    driversRef.child(currentfirebaseUser!.uid).child("token").set(token);

    firebaseMessaging.subscribeToTopic("alldrivers");
    firebaseMessaging.subscribeToTopic("allusers");
  }

  String getRideRequestId(Map<String, dynamic> message)
  {

    String rideRequestId = "";
    if(Platform.isAndroid)
    {
      print("This is request Id :: ");
      rideRequestId = message['ride_request_id'];
      print(rideRequestId);
    }
    else
    {

      rideRequestId = message['ride_request_id'];


    }

    return rideRequestId;
  }



  void retrieveRideRequestInfo(String rideRequestId, BuildContext context)
  {
    newRequestsRef.child(rideRequestId).once().then((DataSnapshot dataSnapShot)

    {


      // name = dataSnapShot.value;
      // print("one::::::::::::::::: $name");











      if(dataSnapShot.value != null)
      {


        assetsAudioPlayer.open(Audio("sounds/alert.mp3"));
        assetsAudioPlayer.play();

          print(rideRequestId);

        double pickUpLocationLat = double.parse(dataSnapShot.value['pickup']['latitude'].toString());
        double pickUpLocationLng = double.parse(dataSnapShot.value['pickup']['longitude'].toString());
        String pickUpAddress = dataSnapShot.value['pickup_address'].toString();



        double dropOffLocationLat = double.parse(dataSnapShot.value['dropoff']['latitude'].toString());
        double dropOffLocationLng = double.parse(dataSnapShot.value['dropoff']['longitude'].toString());
        String dropOffAddress = dataSnapShot.value['dropoff_address'].toString();

        String paymentMethod = dataSnapShot.value['payment_method'].toString();

        String rider_name = dataSnapShot.value["rider_name"];
        String rider_phone = dataSnapShot.value["rider_phone"];

        print(dropOffAddress+pickUpAddress+rider_name );
        RideDetails rideDetails = RideDetails();
        rideDetails.ride_request_id = rideRequestId;
        rideDetails.pickup_address = pickUpAddress;
        rideDetails.dropoff_address = dropOffAddress;
        rideDetails.pickup = LatLng(pickUpLocationLat, pickUpLocationLng);
        rideDetails.dropoff = LatLng(dropOffLocationLat, dropOffLocationLng);
        rideDetails.payment_method = paymentMethod;
        rideDetails.rider_name = rider_name;
        rideDetails.rider_phone = rider_phone;


        print(rideDetails.pickup_address);
        print(rideDetails.dropoff_address);

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => NotificationDialog(rideDetails: rideDetails,),
        );


      }else{
        print("this is xxxxxxxxmethod::::::::::::::${rideRequestId}");
     }
    });

   // print("use this ::::${value}");
  }
 }