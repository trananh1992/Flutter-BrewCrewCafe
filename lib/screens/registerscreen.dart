import 'package:brew_crew_cafe/layouts/custominfodialog.dart';
import 'package:brew_crew_cafe/models/crewuser.dart';
import 'package:brew_crew_cafe/providers/authprovider.dart';
import 'package:brew_crew_cafe/providers/concheck.dart';
import 'package:brew_crew_cafe/providers/crewprovider.dart';
import 'package:brew_crew_cafe/providers/databaseprovider.dart';
import 'package:brew_crew_cafe/screens/homepagescreen.dart';
import 'package:brew_crew_cafe/screens/signinscreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:brew_crew_cafe/layouts/errormsgmaker.dart';
import 'package:shortid/shortid.dart';

class RegisterScreen extends StatefulWidget {
  static const routename = '/registerscreen';

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool newTeamToggle = false;
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _crewNameController = TextEditingController();
  final _crewIdController = TextEditingController();
  bool authstatus = true;

  bool _isLoading = false;
  String loadingMsg = "";

  Map<String, String> _authData = {
    'email': '',
    'password': '',
    'name': '',
    'crewname': '',
    'crewid': '',
  };

  Future<void> _joinYourCrew() async {
    //print('Join Your Crew Button Pressed');
    if (!_formKey.currentState.validate()) {
      //print('Form Keys Are Not Valid');
      return;
    }
    //print('Validator Validated the form keys');
    _formKey.currentState.save();
    //print('Form state is now saved');
    setState(() {
      loadingMsg = "☕We are checking your 🆔 Crew ID and 🔐Authenticating you to your 👨‍👩‍👧‍👦 Crew Members\nPlease wait...";
      _isLoading = true;
    });


    bool concheck = await ConCheck.checkData();

    if(concheck){

    // ? Checking EnteredCrewId exists or not
    int existStatus = await Provider.of<CrewProvider>(context, listen: false)
        .checkCrewIDExist(crewid: _authData['crewid']);
    if (existStatus == 0) {
      setState(() {
        _isLoading = false;
      });
      CustomInfoDialog.showInfoDialog(
          ctx: context,
          title: 'Crew Id not Found',
          message:
              'We are 😔 Sorry to say but the entered 🆔 Crew Id is not found in our cafe, Please 🔄 Recheck the Crew Id and Try again.');
      return;
    } else {

      setState(() {
        loadingMsg = "Great ☕☕ your entered 🆔 Crew Id is valid in our Cafe\n Please wait while we 🔐 Register you as our Cafe member";
      });

      //print('Now lets go for signup');
      String authid = await Provider.of<AuthProvider>(context, listen: false)
          .signUpWithEmail(
              email: _authData['email'], password: _authData['password'])
          .catchError((onError) {
        print(onError);
        String emsg = ErrorMsgMaker.msgMaker(error: onError.toString());
        print(emsg);
        CustomInfoDialog.showInfoDialog(
          title: 'Registration Failed!',
          ctx: context,
          message: emsg,
        );
        setState(() {
          _isLoading = false;
        });
        //print('everything now finished with errors');
        authstatus = false;
        return;
      });

      if (authstatus) {

        setState(() {
          loadingMsg = "Superb ☕ You are now 🔐Authenticated member of our ☕Cafe\n Please wait while we 🔌connect you with your 👨‍👩‍👧‍👦 Crew Members\n📊FACT: A Coffee ☕Brewed with patience is the 💛Best Coffee of your day.";
        });

        String crewname =
            await Provider.of<CrewProvider>(context, listen: false)
                .findCrewNameFromCrewID(_authData['crewid']);
        await Provider.of<CrewProvider>(context, listen: false)
            .addUserInCrewNodes(
                authid, _authData['crewid'], _authData['name'], crewname);
        List<CrewUser> crewList =
            await Provider.of<CrewProvider>(context, listen: false)
                .fetchCrewMembersFromCloud(authid);

        String dbres =
            await Provider.of<DatabaseProvider>(context, listen: false)
                .deleteTable();
        if (dbres == "All Ok") {
          int status =
              await Provider.of<DatabaseProvider>(context, listen: false)
                  .insertCrewMembers(crewList);
          if (status == 0) {
            CustomInfoDialog.showInfoDialog(
                title: 'Problem Occured',
                ctx: context,
                message:
                    'Some Internal problem occured please reinstall the app');
            setState(() {
              _isLoading = false;
            });
            return;
          } else {
           // print(
           //     'Every Process of Registration Completed now I can move to HomeScreen');
            Navigator.of(context)
                .pushReplacementNamed(HomePageScreen.routename);
          }
        } // Internal Database Check and table deletion response
      } // AuthCheck If Condition

    } // Else bracket which works when crewid is valid
  
  } // Internet Connection Check 
  else{
    setState(() {
      loadingMsg = "😟Unable to 🔌Connect to 🌐Internet";
      _isLoading = false;
    });
    CustomInfoDialog.showInfoDialog(ctx: context, title: "Unable to connect", message: "Our Cafe is unable to connect to the internet, Please check your network connection settings or contact your IT Administration for more help.");

  }
  
  } // Join your crew bracket which is called at button press

  Future<void> _startYourCrew() async {
   // print('Start Your Crew Button Pressed');
    if (!_formKey.currentState.validate()) {
      //print('Form Keys Are Not Valid');
      return;
    }
    //print('Validator Validated the form keys');
    _formKey.currentState.save();
    //print('Form state is now saved');
    
    setState(() {
       loadingMsg = "☕We are brewing your 🆔 Crew Name to get a special CrewID Just for you and your 👨‍👩‍👧‍👦 Crew Members\nPlease wait...";
      _isLoading = true;
    });

    bool concheck = await ConCheck.checkData();

    if(concheck){

    shortid.characters(
        '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ@!');
    String newId =
        _authData['crewname'].replaceAll(' ', '') + '-' + shortid.generate();
    print(newId);

    setState(() {
      loadingMsg = "We just prepared your Unique 🆔 CrewID for you & your 👨‍👩‍👧‍👦 Crew Members, Now let us 🔐Authenticate you.\nPlease Wait...";
    });

    //print('Now lets go for signup');
    String authid = await Provider.of<AuthProvider>(context, listen: false)
        .signUpWithEmail(
            email: _authData['email'], password: _authData['password'])
        .catchError((onError) {
      print(onError);
      String emsg = ErrorMsgMaker.msgMaker(error: onError.toString());
      print(emsg);
      CustomInfoDialog.showInfoDialog(
        title: 'Registration Failed!',
        ctx: context,
        message: emsg,
      );
      setState(() {
        _isLoading = false;
      });
     // print('everything now finished with errors');
      authstatus = false;
      return;
    });

    if (authstatus) {
        
      setState(() {
        loadingMsg = "Great☕ You are now 🔐 Authenticated member of our ☕Cafe, Please wait...\n And don't forget to invite your 👨‍👩‍👧‍👦 friends by sharing our ☕Cafe with them.";
      });

      CrewUser crewUser =
          await Provider.of<CrewProvider>(context, listen: false)
              .addNewCrewNodes(
                  authid: authid,
                  crewid: newId,
                  crewname: _authData['crewname'],
                  username: _authData['name'])
              .catchError((error) {
        String emsg = ErrorMsgMaker.msgMaker(error: error.toString());
        print(emsg);
        CustomInfoDialog.showInfoDialog(
            title: 'Problem Occured', ctx: context, message: emsg);
        setState(() {
          _isLoading = false;
        });
        return;
      });

      //print('Came at the position to add a list item');
      List<CrewUser> list = List<CrewUser>();
      list.add(crewUser);

      String dbres = await Provider.of<DatabaseProvider>(context, listen: false)
          .deleteTable();
      if (dbres == "All Ok") {
        int status = await Provider.of<DatabaseProvider>(context, listen: false)
            .insertCrewMembers(list);
        if (status == 0) {
          CustomInfoDialog.showInfoDialog(
              title: 'Problem Occured',
              ctx: context,
              message:
                  'Some Internal problem occured please reinstall the app');
          setState(() {
            _isLoading = false;
          });
          return;
        } // Database value inserted in database
        else {
          setState(() {
            _isLoading = false;
          });
          Navigator.of(context).pushReplacementNamed(HomePageScreen.routename);
        }
      } // Internal Database Check and table deletion response
    } // authstatus validator works after signup
   } // Internet checker
    else{
    setState(() {
      loadingMsg = "😟Unable to 🔌Connect to 🌐Internet";
      _isLoading = false;
    });
    CustomInfoDialog.showInfoDialog(ctx: context, title: "Unable to connect", message: "Our Cafe is unable to connect to the internet, Please check your network connection settings or contact your IT Administration for more help.");

  }
  } // startyourcrew function

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.3, left: 30, right: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text(
                    loadingMsg,
                   
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Container(
                margin:
                    EdgeInsets.only(left: 20, right: 20, top: 70, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    RichText(
                      text: TextSpan(
                        style: theme.primaryTextTheme.subhead,
                        children: <TextSpan>[
                          const TextSpan(text: 'Welcome to\n'),
                          TextSpan(
                            text: 'Brew Crew\n',
                            style: theme.primaryTextTheme.headline,
                          ),
                          const TextSpan(text: 'Cafe'),
                        ],
                      ),
                    ),
                    Divider(),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(top: 20),
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                  width: 2, color: theme.primaryColor),
                            ),
                            child: Column(
                              children: <Widget>[
                                Text('Register New User',
                                    style: theme.primaryTextTheme.body1),
                                const SizedBox(height: 20),
                                TextFormField(
                                  validator: (value) {
                                    if (value.isEmpty)
                                      return "Please enter your name";
                                  },
                                  onSaved: (value) {
                                    _authData['name'] = value;
                                  },
                                  decoration: InputDecoration(
                                      icon: Icon(Icons.person,
                                          color: Colors.brown[800]),
                                      labelText: 'Name'),
                                ),
                                TextFormField(
                                  validator: (value) {
                                    if (value.isEmpty ||
                                        value.length < 5 ||
                                        !value.contains('@'))
                                      return "Invalid Email Format";
                                  },
                                  onSaved: (value) {
                                    _authData['email'] = value;
                                  },
                                  decoration: InputDecoration(
                                      icon: Icon(Icons.email,
                                          color: Colors.brown[800]),
                                      labelText: 'Email'),
                                ),
                                TextFormField(
                                  obscureText: true,
                                  validator: (value) {
                                    if (value.isEmpty || value.length < 5)
                                      return "Password Format Invalid";
                                  },
                                  onSaved: (value) {
                                    _authData['password'] = value;
                                  },
                                  decoration: InputDecoration(
                                      icon: Icon(Icons.lock,
                                          color: Colors.brown[800]),
                                      labelText: 'Password'),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          ),
                          !newTeamToggle
                              ? Column(
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.only(top: 20),
                                      padding: EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                            width: 2,
                                            color: theme.primaryColor),
                                      ),
                                      child: Column(
                                        children: <Widget>[
                                          Text('Crew Details',
                                              style:
                                                  theme.primaryTextTheme.body1),
                                          const SizedBox(height: 20),
                                          const Text(
                                              'Enter Your Crew ID received from your \nCrew or Captain'),
                                          Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: TextFormField(
                                                  validator: (value) {
                                                    if (value.isEmpty ||
                                                        value.length > 32)
                                                      return "Invalid CrewId Format";
                                                  },
                                                  onSaved: (value) {
                                                    _authData['crewid'] = value;
                                                  },
                                                  decoration:
                                                      const InputDecoration(
                                                          icon:
                                                              Icon(Icons.group),
                                                          labelText: 'Crew ID'),
                                                ),
                                              ),
                                              
                                            ],
                                          ),

                                          const SizedBox(height: 20),
                                          RaisedButton(
                                            onPressed: () {
                                              setState(() {
                                                newTeamToggle = !newTeamToggle;
                                              });
                                            },
                                            child: const Text(
                                                'Create a New Brew Crew Team'),
                                          )

                                          // ...
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        Container(
                                          alignment: Alignment.center,
                                          child: RaisedButton(
                                            child: const Text('LOGIN'),
                                            onPressed: () {
                                              Navigator.of(context).pushNamed(
                                                  SignInScreen.routename);
                                            },
                                          ),
                                        ),
                                        Container(
                                          alignment: Alignment.center,
                                          child: RaisedButton(
                                            child: const Text('JOIN YOUR CREW'),
                                            onPressed: _joinYourCrew,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                )
                              : Column(
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.only(top: 20),
                                      padding: EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                            width: 2,
                                            color: theme.primaryColor),
                                      ),
                                      child: Column(
                                        children: <Widget>[
                                          Text('New Crew Details',
                                              style:
                                                  theme.primaryTextTheme.body1),
                                          const SizedBox(height: 20),
                                          const Text(
                                              'To create your own brew crew team,\nEnter your Crew team name'),
                                          TextFormField(
                                            validator: (value) {
                                              if (value.isEmpty ||
                                                  value.length > 32)
                                                return "Invalid Crew Name Format";
                                            },
                                            onSaved: (value) {
                                              _authData['crewname'] = value;
                                            },
                                            decoration: const InputDecoration(
                                                icon: Icon(Icons.group),
                                                labelText: 'Unique Crew Name'),
                                          ),
                                          const SizedBox(height: 20),
                                          RaisedButton(
                                            onPressed: () {
                                              setState(() {
                                                newTeamToggle = !newTeamToggle;
                                              });
                                            },
                                            child: const Text(
                                                'Join your existing Crew'),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        Container(
                                          alignment: Alignment.center,
                                          child: RaisedButton(
                                            child: const Text('LOGIN'),
                                            onPressed: () {
                                              Navigator.of(context).pushNamed(
                                                  SignInScreen.routename);
                                            },
                                          ),
                                        ),
                                        Container(
                                          alignment: Alignment.center,
                                          child: RaisedButton(
                                            child:
                                                const Text('START YOUR CREW'),
                                            onPressed: _startYourCrew,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
