import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:spacex/services/launch_service.dart';

import 'models/launch.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var launchService = LaunchService();
    return FutureProvider(
      create: (context) => launchService.fetchLaunch(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          brightness: Brightness.dark,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Home(),
      ),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Timer timer;
  Launch launch;
  String countdown;

  @override
  void initState() {
    countdown = '';
   timer = Timer.periodic(Duration(seconds: 1), (timer) {
     if (launch != null){
       var diff = launch.launchUTC.difference(DateTime.now().toUtc());
       setState(() {
         countdown = durationToString(diff);
       });
     }
     });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    launch = Provider.of<Launch>(context);

    return Scaffold(
        appBar: AppBar(
          title: Text('SpaceX Launch Tracker', style: GoogleFonts.ubuntu()),
          centerTitle: true,
        ),
        body: (launch != null)
            ? Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text('Next Launch',
                              style: GoogleFonts.ubuntu(
                                  fontSize: 12.0, color: Colors.yellow)),
                          Text(countdown,
                              style: GoogleFonts.sourceCodePro(fontSize: 50.0)),
                          Text(launch.rocket.rocketName,
                              style: GoogleFonts.ubuntu(fontSize: 25.0)),
                        ],
                      ),
                    ),
                    Flexible(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 50.0),
                          child: Image.asset('assets/rocket.png'),
                        ))
                  ],
                ),
              )
            : Center(
                child: CircularProgressIndicator(),
              ));
  }

  String durationToString(Duration duration){
    String twoDigits(int n){
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}
