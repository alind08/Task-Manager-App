import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart' as location;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_intent/android_intent.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    requestLocationPermission();
    _gpsService();
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOS = new IOSInitializationSettings();
    var initSetttings = new InitializationSettings(android, iOS);
    flutterLocalNotificationsPlugin.initialize(initSetttings,
        onSelectNotification: null);
  }

  final PermissionHandler permissionHandler = PermissionHandler();
  Map<PermissionGroup, PermissionStatus> permissions;
  Future<bool> _requestPermission(PermissionGroup permission) async {
    final PermissionHandler _permissionHandler = PermissionHandler();
    var result = await _permissionHandler.requestPermissions([permission]);
    if (result[permission] == PermissionStatus.granted) {
      return true;
    }
    return false;
  }

  Future<bool> requestLocationPermission({Function onPermissionDenied}) async {
    var granted = await _requestPermission(PermissionGroup.location);
    if (granted!=true) {
      requestLocationPermission();
    }
    debugPrint('requestContactsPermission $granted');
    return granted;
  }

  Future _checkGps() async {
    if (!(await Geolocator().isLocationServiceEnabled())) {
      if (Theme.of(context).platform == TargetPlatform.android) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Can't get gurrent location"),
                content:const Text('Please make sure you enable GPS and try again'),
                actions: <Widget>[
                  FlatButton(child: Text('Ok'),
                      onPressed: () {
                        final AndroidIntent intent = AndroidIntent(
                            action: 'android.settings.LOCATION_SOURCE_SETTINGS');
                        intent.launch();
                        Navigator.of(context, rootNavigator: true).pop();
                        _gpsService();
                      })],
              );
            });
      }
    }
  }

  Future _gpsService() async {
    if (!(await Geolocator().isLocationServiceEnabled())) {
      _checkGps();
      return null;
    } else
      return true;
  }

  Widget _taskPart(String property,String value) {
    return Container(
      margin: EdgeInsets.all(15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(property,style: propTextStyle,),
          Text(value,style: valueTextStyle,),
        ],
      )
    );
  }
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          centerTitle: true,
          elevation: 0.0,
          leading: Icon(Icons.menu),
          title: Text("ORMAE"),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.exit_to_app,
                color: Colors.white,
              ),
              onPressed: () {
                // do something
              },
            )
          ],
        ),
        body: Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height/2,
              color: Colors.blueAccent,
              child: Column(
                children: <Widget>[
                  Container(
                    child: Center(
                        child: Text("Task OverView",style: myTextStyle,)
                    ),
                  ),
                  SizedBox(width: 100,),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              _taskPart("Total Capacity", "10m"),
                              SizedBox(
                                width: MediaQuery.of(context).size.height/5,
                                height: 0.5,
                                child: Container(color: Colors.white,),
                              ),
                              _taskPart("Demand", "10,000"),
                              SizedBox(
                                width: MediaQuery.of(context).size.height/5,
                                height: 0.5,
                                child: Container(color: Colors.white,),
                              ),
                              _taskPart("Start time", "9:30")
                            ],
                          ),
                        ),
                        SizedBox(width: 20,),
                        SizedBox(
                          width: 0.5,
                          height: MediaQuery.of(context).size.height/2.5,
                          child: Container(color: Colors.white,),
                        ),
                        SizedBox(width: 20,),
                        Container(
                          child: Row(
                            children: <Widget>[
                              Container(
                                child: Column(
                                  children: <Widget>[
                                    _taskPart("Total Distance", "241km"),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.height/5,
                                      height: 0.5,
                                      child: Container(color: Colors.white,),
                                    ),
                                    _taskPart("Location", "BLR"),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.height/5,
                                      height: 0.5,
                                      child: Container(color: Colors.white,),
                                    ),
                                    _taskPart("End Time", "19:39")
                                  ],
                                ),
                              ),

                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(MediaQuery.of(context).size.height/8),
              color: Colors.white,
              child:RaisedButton(
                  child: Text("Start Task"),
                onPressed: showNotification,
                ),
            )
          ],
        ),
      ),
    );
  }
  showNotification() async {
    var android = new AndroidNotificationDetails(
        'channel id', 'channel NAME', 'CHANNEL DESCRIPTION',
        priority: Priority.High,importance: Importance.Max
    );
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, iOS);
    await flutterLocalNotificationsPlugin.show(
        0, 'Ormae', 'Task Started', platform,
        payload: 'orame tasks');
  }
}


TextStyle myTextStyle = TextStyle(
    fontSize: 38,
    fontWeight: FontWeight.w200,
    color: Colors.white);

TextStyle propTextStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w300,
    color: Colors.white);

TextStyle valueTextStyle = TextStyle(
    fontSize: 38,
    fontWeight: FontWeight.w400,
    color: Colors.white);