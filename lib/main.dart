// @dart=2.9
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
 import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:driver_app/AllScreen/loginScreen.dart';
import 'package:driver_app/AllScreen/mainscreen.dart';
import 'package:driver_app/AllScreen/registerationScreen.dart';
import 'package:driver_app/DataHandler/appData.dart';

import 'AllScreen/carInfoScreen.dart';
import 'configMaps.dart';


const AndroidNotificationChannel channel = AndroidNotificationChannel(
'high_importance_channel',//id
'High Importance Notifications' ,//title
 'This channel is used for Important Notification',//description
  importance: Importance.high,
  playSound: true


);

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {

  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}


Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  currentfirebaseUser = FirebaseAuth.instance.currentUser;
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler) ;
  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true

  );
  runApp(MyApp());
}

DatabaseReference usersRef = FirebaseDatabase.instance.reference().child("users");
DatabaseReference driversRef = FirebaseDatabase.instance.reference().child("drivers");
DatabaseReference rideRequestRef = FirebaseDatabase.instance.reference().child("drivers").child(currentfirebaseUser.uid).child("newRide");
DatabaseReference newRequestsRef = FirebaseDatabase.instance.reference().child("Ride Requests");


class MyApp extends StatefulWidget {
  // This widget is the root of your application.


  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  // @override
  // void initState(){
  //  super.initState();
  //   // Add code after super
  //  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //
  //    RemoteNotification? notification = message.notification;
  //    AndroidNotification? android = message.notification?.android;
  //    if (notification != null && android != null) {
  //      flutterLocalNotificationsPlugin.show(
  //          notification.hashCode,
  //          notification.title,
  //          notification.body,
  //          NotificationDetails(
  //            android: AndroidNotificationDetails(
  //              channel.id,
  //              channel.name,
  //              channel.description,
  //              color: Colors.blue,
  //              playSound: true,
  //              icon: '@mipmap/ic_launcher',
  //            ),
  //          ));
  //    }
  //  });
  //
  //
  //  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  //    print('A new onMessageOpenedApp event was published!');
  //    RemoteNotification? notification = message.notification;
  //    AndroidNotification? android = message.notification?.android;
  //    if (notification != null && android != null) {
  //      showDialog(
  //          context: context,
  //          builder: (_) {
  //            return AlertDialog(
  //              title: Text(notification.title!),
  //              content: SingleChildScrollView(
  //                child: Column(
  //                  crossAxisAlignment: CrossAxisAlignment.start,
  //                  children: [Text(notification.body!)],
  //                ),
  //              ),
  //            );
  //          });
  //    }
  //  });
  // }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>AppData(),
      child: MaterialApp(
        title: 'Taxi Driver App',
        theme: ThemeData(
          fontFamily: "Brand Bold",
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity
        ),
        initialRoute: FirebaseAuth.instance.currentUser == null ? LoginScreen.idScreen : MainScreen.idScreen,
        routes: {
          RegisterationScreen.idScreen:(context)=>RegisterationScreen(),
          LoginScreen.idScreen:(context)=>LoginScreen(),
          MainScreen.idScreen:(context)=>MainScreen(),
          CarInfoScreen.idScreen:(context)=>CarInfoScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }



}


