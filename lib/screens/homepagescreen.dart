import 'package:brew_crew_cafe/layouts/crewpreftile.dart';
import 'package:brew_crew_cafe/providers/crewprovider.dart';
import 'package:brew_crew_cafe/screens/brewdrawer.dart';
import 'package:brew_crew_cafe/screens/coffeeprefscreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class HomePageScreen extends StatefulWidget {
  static const routename = '/homepagescreen';

  @override
  _HomePageScreenState createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();


  
  }

  final String shareMessage =
      'Hey!! Join us on Brew Crew Cafe, https://play.google.com/store/apps/details?id=com.akshaybengani.brewcrewcafe \nAn app for coffee enthusiasts, Use this crew code to join the revolution.';

  @override
  Widget build(BuildContext context) {
    final crewData = Provider.of<CrewProvider>(context, listen: true).crewlist;
    // final crewData = crewProd.crewlist;
    // final authID = crewProd.findByAuthID('001').crewID;
    final authID = 001;
    return _isLoading
        ? Scaffold(
            appBar: AppBar(
              title:
                  Expanded(child: Text('Brewing your crew, Please Wait ...')),
            ),
            body: Center(child: CircularProgressIndicator()),
          )
        : Scaffold(
            drawer: BrewDrawer(),
            appBar: AppBar(
              title: Text('Brew Crew Cafe'),
              actions: <Widget>[
                FlatButton.icon(
                  icon: Icon(Icons.edit, color: Colors.white),
                  textColor: Colors.white,
                  onPressed: () {
                    Navigator.of(context).pushNamed(CoffeePrefScreen.routename);
                  },
                  label: Text('Edit'),
                ),
              ],
            ),
            body: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/coffee_bg.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          crewData[0].crewname,
                          style: TextStyle(
                              fontSize: 30,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      FlatButton.icon(
                        icon: Icon(
                          Icons.share,
                          color: Colors.brown[800],
                        ),
                        onPressed: () {
                          Share.share('$shareMessage $authID');
                        },
                        label: Text(
                          'Invite',
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.68,
                    child: ListView.builder(
                      itemCount: crewData.length,
                      itemBuilder: (context, index) => CrewPrefTile(
                        name: crewData[index].name,
                        bio: crewData[index].bio,
                        coffeeIntensity: crewData[index].coffeeintensity,
                        sugarIntensity: crewData[index].sugarintensity,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
