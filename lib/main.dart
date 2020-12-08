import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paysee/Join/root_page.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(
    /// 1. Wrap your App widget in the Phoenix widget
    Phoenix(
      child: PaySee_App(),
    ),
  );
}

class PaySee_App extends StatelessWidget {
  // This widget is the root of your application.
  @override

  Widget build(BuildContext context) {
    //세로방향 고정처리
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitDown,DeviceOrientation.portraitUp,]);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PaySee Mobile Service',
      initialRoute: '/',
      localizationsDelegates: [ GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate,],
      supportedLocales: [
//        const Locale('en', 'US'),
        const Locale('ko', 'KO'),
      ],
      theme: ThemeData(
          primarySwatch: Colors.blue
      ),
      home: Root_Page(),
    );
  }
}