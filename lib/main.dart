import 'package:brew_crew_cafe/backend/authprovider.dart';
import 'package:brew_crew_cafe/backend/crewprovider.dart';
import 'package:brew_crew_cafe/screens/brewdrawer.dart';
import 'package:brew_crew_cafe/screens/coffeeprefscreen.dart';
import 'package:brew_crew_cafe/screens/homepagescreen.dart';
import 'package:brew_crew_cafe/screens/managecrewscreen.dart';
import 'package:brew_crew_cafe/screens/registerscreen.dart';
import 'package:brew_crew_cafe/screens/signinscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: AuthProvider(),
        ),
        ChangeNotifierProvider.value(
          value: CrewProvider(),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Brew Crew Cafe',
        theme: ThemeData(
          primaryColor: Colors.brown[800],
          accentColor: Colors.brown[300],
          backgroundColor: Colors.brown[100],
          dividerTheme:
              DividerThemeData(color: Colors.brown[300], thickness: 5),
          cursorColor: Colors.brown[800],

          //iconTheme: IconThemeData(color: Colors.brown[800]),
          //accentIconTheme: IconThemeData(color: Colors.brown[800]),
          //primaryIconTheme: IconThemeData(color: Colors.brown[800]),
          cardTheme: CardTheme(
            color: Colors.white,
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(width: 3),
            ),
          ),
          primaryTextTheme: TextTheme(
            headline: TextStyle(
                fontSize: 50,
                color: Colors.brown[800],
                fontWeight: FontWeight.bold),
            subhead: TextStyle(fontSize: 30, color: Colors.black),
            body1: TextStyle(
                color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold),
            button: TextStyle(
                color: Colors.white,
                backgroundColor: Colors.brown[800],
                fontWeight: FontWeight.bold),
          ),
          buttonTheme: ButtonThemeData(
              buttonColor: Colors.brown[800],
              textTheme: ButtonTextTheme.primary),
          appBarTheme: AppBarTheme(
            color: Colors.brown[800],
            textTheme: TextTheme(
              // Add Fonts and set Font style
              title: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ),
        home: MyHomeApp(),
        //home: SignInScreen(),
        routes: {
          SignInScreen.routename: (ctx) => SignInScreen(),
          RegisterScreen.routename: (ctx) => RegisterScreen(),
          HomePageScreen.routename: (ctx) => HomePageScreen(),
          CoffeePrefScreen.routename: (ctx) => CoffeePrefScreen(),
          ManageCrewScreen.routename: (ctx) => ManageCrewScreen(),
          BrewDrawer.routename: (ctx) => BrewDrawer(),
        },
      ),
    );
  }
}

class MyHomeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          if (snapshot.hasData) {
            return HomePageScreen();
          } else {
            return SignInScreen();
          }
        }
      },
    );
  }
}
