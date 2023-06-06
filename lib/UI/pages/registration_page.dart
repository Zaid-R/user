import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pharmacy_in_pocket/UI/model/auth.dart';
import 'package:provider/provider.dart';
import '../widgets/field.dart';

class RegistrationPage extends StatefulWidget {
  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

//Sit dolor veniam veniam exercitation do ipsum ex aute eiusmod. Deserunt aute ullamco laboris fugiat esse. Amet sunt officia cillum proident ut aliquip anim laboris laboris. Excepteur ullamco consectetur culpa fugiat mollit magna eiusmod. Laboris non cillum est ad minim commodo ex nulla nulla cupidatat pariatur occaecat tempor ullamco. Quis proident irure tempor elit. Minim Lorem nisi ullamco ad cupidatat ex deserunt proident laboris pariatur anim ipsum nulla incididunt.
enum authMode { logIn, signUp }

class _RegistrationPageState extends State<RegistrationPage> {
  String _radioValue = 'Amman';
  Color myPurple = const Color.fromRGBO(93, 63, 211, 1);
  final Map<String, String?> _authData = {
    "name": "",
    "email": "",
    "password": "",
    "city": "",
    'phoneNumber': '',
  };

  final GlobalKey<FormState> _formKey = GlobalKey();
  final _passwordController = TextEditingController();
  List cities = [];
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    TextStyle linkTextStyle = TextStyle(
        color: myPurple,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
        wordSpacing: 2);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: myPurple,
          title: const Text('Pharmacy In Pocket'),
          centerTitle: true,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.grey.shade300,
                  myPurple,
                ]),
          ),
          alignment: Alignment.center,
          //Container to stand out the from of registration
          child:
              //Use material to add elevation for form container
              Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Material(
              elevation: 10,
              //To avoid bad corners give the same borderRadius for material and container
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                width: screenWidth * 0.8,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(20)),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Field(
                            title: 'Email',
                            isObscureText: false,
                            inputType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value != null &&
                                  (value.isEmpty || !value.contains('@'))) {
                                return 'Invalid email';
                              }
                              return null;
                            },
                            onSaved: (newValue) => setState(
                                () => _authData['email'] = newValue!.trim()),
                            width: screenWidth * 0.6),
                        Field(
                            title: 'Password',
                            isObscureText: true,
                            inputType: TextInputType.text,
                            controller: _passwordController,
                            validator: (value) {
                              if (value != null) {
                                if ((value.isEmpty || value.length <= 5) &&
                                    _authMode == authMode.logIn) {
                                  return 'Password should be at least 6 digits';
                                }
                                //Complete this after dealing with database
                                /* else if (authMode == authMode.signUp&&value!= passwordInDB) {
                            return 'Wrong password';
                          } */
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              setState(() {
                                _authData['password'] = newValue;
                              });
                            },
                            width: screenWidth * 0.6),
                        //Display forgot password only in login page
                        if (_authMode == authMode.logIn)
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: Text(
                              'Forgot password?',
                              style: linkTextStyle,
                            ),
                          ),
                        //Display this widgets when user want to create new account
                        if (_authMode == authMode.signUp)
                          Column(
                            children: [
                              //Confirm password field
                              Field(
                                  title: 'Confirm password',
                                  isObscureText: true,
                                  validator: (value) {
                                    return value != _passwordController.text
                                        ? 'Password doesn\'t match'
                                        : null;
                                  },
                                  width: screenWidth * 0.6),
                              //username textField
                              Field(
                                  title: 'Username',
                                  validator: (value) {
                                    return value!.isEmpty
                                        ? 'Enter your username'
                                        : null;
                                  },
                                  onSaved: (name) => setState(
                                      () => _authData['name'] = name!.trim()),
                                  width: screenWidth * 0.6),
                              //Phone number textField
                              Field(
                                  inputType: TextInputType.phone,
                                  title: 'Phone number',
                                  hint: '07 #### ####',
                                  validator: (value) {
                                    if (value != null) {
                                      if (value.length != 10) {
                                        return 'Phone number must be 10 digits';
                                      } else if (int.parse(
                                              value.substring(0, 2)) !=
                                          7) {
                                        return 'Phone number must start with 07';
                                      } else if (int.parse(value[2]) < 7) {
                                        return 'Third digit of phone number must be 7,8 or 9';
                                      }
                                      return null;
                                    }
                                    return 'Enter your phone number';
                                  },
                                  onSaved: (phoneNumber) => setState(() =>
                                      _authData['phoneNumber'] = phoneNumber),
                                  width: screenWidth * 0.6),
                              const SizedBox(
                                height: 20,
                              ),
                              //
                              //Select the city
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    width: 50,
                                  ),
                                  Builder(builder: (ctx) {
                                    return ElevatedButton(
                                      onPressed: () async {
                                        var x = await FirebaseFirestore.instance
                                            .collection('cities')
                                            .doc('choosenCities')
                                            .get();
                                        setState(() {
                                          cities = x.data()!['cities'];
                                        });
                                        // ignore: use_build_context_synchronously
                                        showDialog(
                                            context: ctx,
                                            builder: (_) => AlertDialog(
                                                  content: StatefulBuilder(
                                                      builder: (_, function) {
                                                    return Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: cities
                                                          .map((cityName) =>
                                                              RadioListTile(
                                                                title: Text(
                                                                    cityName),
                                                                value: cityName,
                                                                groupValue:
                                                                    _radioValue,
                                                                onChanged:
                                                                    (newName) {
                                                                  //Change the _radioValue inside function to change the selected RadioButton
                                                                  function(() =>
                                                                      _radioValue =
                                                                          newName!);
                                                                  //Change the _radioValue inside setState to change the city's name label  of choosen city
                                                                  setState(() {
                                                                    _radioValue =
                                                                        newName!;
                                                                    _authData[
                                                                            'city'] =
                                                                        newName;
                                                                  });
                                                                },
                                                              ))
                                                          .toList(),
                                                    );
                                                  }),
                                                ));
                                      },
                                      child: const Text('Select your city',
                                          style: TextStyle(fontSize: 15)),
                                    );
                                  }),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Container(
                                      decoration: BoxDecoration(
                                          color: Colors.grey[500],
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      padding: const EdgeInsets.all(10),
                                      child: Text(
                                        _radioValue,
                                        style: const TextStyle(fontSize: 20),
                                      ))
                                ],
                              ),
                            ],
                          ),
                        const Divider(
                            thickness: 2, color: Colors.grey, height: 50),
                        !Provider.of<Auth>(context).isLoading
                            ? Column(
                                children: [
                                  ElevatedButton(
                                    onPressed: _submit,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        _authMode == authMode.logIn
                                            ? 'Log in'
                                            : 'Sign up',
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: screenHeight * 0.03,
                                  ),
                                  TextButton(
                                    onPressed: _switchAuthMode,
                                    style: const ButtonStyle(
                                        backgroundColor:
                                            MaterialStatePropertyAll(
                                                Colors.transparent)),
                                    child: Text(
                                        '${_authMode == authMode.logIn ? 'Create a new' : 'Already have'} account',
                                        style: linkTextStyle),
                                  ),
                                ],
                              )
                            : const CircularProgressIndicator(),
                        const SizedBox(height: 20)
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ));
  }

  authMode _authMode = authMode.logIn;
  void _switchAuthMode() {
    setState(() => _authMode =
        (_authMode == authMode.logIn ? authMode.signUp : authMode.logIn));
  }

  void _showErrorDialog(String message) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text('An error occurred'),
              content: Text(message),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                  },
                  child: const Text('Okay'),
                )
              ],
            ));
  }

  void _submit() async {
    //make sure the data is valid
    if (!_formKey.currentState!.validate()) return;
    //save the data after passing the condition successfully
    _formKey.currentState!.save();

    
    try {
      var providerAuthMethod = Provider.of<Auth>(context, listen: false);
    providerAuthMethod.setIsLoading(true);
      var gottenUserDoc =
          await FirebaseFirestore.instance.collection('users').doc(_authData['email'].toString()).get();

      bool userExistsAsDoc = gottenUserDoc.exists;
      bool userExistsAsAuth = (await FirebaseAuth.instance
              .fetchSignInMethodsForEmail(_authData['email']!))
          .isNotEmpty;
      if (!userExistsAsDoc && userExistsAsAuth) {
        throw 'Your account has been deleted.';
      } else if (userExistsAsDoc &&
          !userExistsAsAuth &&
          authMode.logIn == _authMode) {
        var data = (await FirebaseFirestore.instance.collection('users').get()).docs
            .firstWhere((element) =>
                element
                    .data()['email']
                    .toString()
                    .compareTo(_authData['email'].toString()) ==
                0)
            .data();
        //If it's admin try to login using his admin account
        if (data['isAdmin'] > 0) {
          throw 'Create user account';
        }
        setState(() {
          _authData['email'] = data['email'];
          _authData['password'] = data['password'];
        });
        try {
          providerAuthMethod.authenticate(
            data['email']!,
            data['password']!,
            data['name']!,
            data['city']!,
            data['phoneNumber']!,
            false,
            true,
          );
        } on FirebaseAuthException catch (e) {
          //if this email isn't in DB, so make the auth mode registration mode
          if (e.code == 'email-already-in-use') {
            FirebaseAuth.instance.signInWithEmailAndPassword(
                email: data['email'], password: data['password']);
          }
        }
      } else {
        await providerAuthMethod.authenticate(
            _authData['email']!,
            _authData['password']!,
            _authData['name']!,
            _authData['city']!,
            _authData['phoneNumber']!,
            authMode.logIn == _authMode,
            false);
      }
    } catch (e) {
      Provider.of<Auth>(context, listen: false)
                        .setIsLoading(false);
      _showErrorDialog(e.toString());
    }
  }
}
