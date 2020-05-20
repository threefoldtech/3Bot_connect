import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/services/3bot_service.dart';
import 'package:threebotlogin/services/open_kyc_service.dart';
import 'package:threebotlogin/services/tools_service.dart';
import 'package:threebotlogin/services/crypto_service.dart';
import 'package:threebotlogin/services/user_service.dart';
import 'package:threebotlogin/widgets/custom_dialog.dart';
import 'package:threebotlogin/widgets/reusable_text_field_step.dart';
import 'package:threebotlogin/widgets/reusable_text_step.dart';

class MobileRegistrationScreen extends StatefulWidget {
  final String doubleName;

  MobileRegistrationScreen({this.doubleName});

  _MobileRegistrationScreenState createState() =>
      _MobileRegistrationScreenState();
}

enum _State { DoubleName, Email, SeedPhrase, ConfirmSeedPhrase, Finish }

class RegistrationData {
  String doubleName = '';
  String phrase = '';
  String email = '';
  Map<String, String> keys;
}

class _MobileRegistrationScreenState extends State<MobileRegistrationScreen> {
  final doubleNameController = TextEditingController();
  final emailController = TextEditingController();
  final seedConfirmationController = TextEditingController();
  _State state = _State.DoubleName;

  bool isVisible = false;

  String phraseConfirmationWords = '';
  String errorStepperText = '';

  final FocusNode nameFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode seedFocus = FocusNode();

  RegistrationData _registrationData = RegistrationData();

  @override
  void initState() {
    if (widget.doubleName != null) {
      setState(() {
        doubleNameController.text = widget.doubleName;
      });
    }
    super.initState();
  }

  void dispose() {
    super.dispose();
  }

  checkEmail() async {
    String email = emailController.text.toLowerCase().trim();

    bool emailValid = validateEmail(email);
    setState(() {
      if (emailValid) {
        _registrationData.email = email;
        state = _State.SeedPhrase;
      } else {
        errorStepperText = "Please enter a valid email.";
      }
    });
  }

  checkDoubleName() async {
    if (doubleNameController.text != null || doubleNameController.text != '') {
      _registrationData.doubleName = doubleNameController.text.toLowerCase() + '.3bot';
      String doubleNameValidation =
          validateDoubleName(doubleNameController.text);
      if (doubleNameValidation == null) {
        Response userInfoResult =
            await getUserInfo(_registrationData.doubleName.toLowerCase());
        if (userInfoResult.statusCode != 200) {
          setState(() {
            state = _State.Email;
          });
        } else {
          setState(() {
            errorStepperText = 'Sorry, this name is already in use.';
          });
        }
      } else {
        setState(() {
          errorStepperText = 'Please enter a valid name.';
        });
      }
    } else {
      setState(() {
        errorStepperText = 'Please choose a name.';
      });
    }
  }

  generateKeys() async {
    setState(() {
      state = _State.ConfirmSeedPhrase;
    });
    _registrationData.keys =
        await generateKeysFromSeedPhrase(_registrationData.phrase);
  }

  checkConfirm() {
    bool seedWordConfirmationValidation = validateSeedWords(
        _registrationData.phrase, seedConfirmationController.text);
    if (seedWordConfirmationValidation) {
      setState(() {
        state = _State.Finish;
      });
    } else {
      setState(() {
        errorStepperText = 'Please enter the correct words.';
      });
    }
  }

  finish() async {
    loadingDialog();
    Response response = await finishRegistration(doubleNameController.text,
        emailController.text, 'random', _registrationData.keys['publicKey']);

    if (response.statusCode == 200) {
      saveRegistration();

      Navigator.pop(context); // Remove loading screen
      Navigator.pop(context, true); // Pop this
    } else {
      Navigator.pop(context); // Remove loading screen

      showDialog(
          context: context,
          builder: (BuildContext context) => CustomDialog(
                image: Icons.error,
                title: 'Error',
                description:
                    'Something went wrong when trying to create your account.',
                actions: <Widget>[
                  FlatButton(
                    child: Text('Ok'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              ));
    }
  }

  initKeys() async {
    if (_registrationData.phrase == null || _registrationData.phrase == '') {
      _registrationData.phrase = await generateSeedPhrase();
    }
  }

  checkStep(currentStep) async {
    switch (currentStep) {
      case _State.DoubleName:
        await checkDoubleName();
        FocusScope.of(context).requestFocus(emailFocus);
        break;
      case _State.Email:
        await checkEmail();
        await initKeys();
        FocusScope.of(context).unfocus();
        break;
      case _State.SeedPhrase:
        await generateKeys();
        FocusScope.of(context).requestFocus(seedFocus);
        break;
      case _State.ConfirmSeedPhrase:
        await checkConfirm();
        FocusScope.of(context).unfocus();
        break;
      case _State.Finish:
        finish();
        break;
      default:
        break;
    }
  }

  checkStepFocus(currentStep) async {
    switch (currentStep) {
      case _State.DoubleName:
        FocusScope.of(context).requestFocus(nameFocus);
        break;
      case _State.Email:
        FocusScope.of(context).requestFocus(emailFocus);
        break;
      case _State.SeedPhrase:
        FocusScope.of(context).unfocus();
        break;
      case _State.ConfirmSeedPhrase:
        FocusScope.of(context).requestFocus(seedFocus);
        break;
      default:
        break;
    }
  }

  void saveRegistration() async {
    savePrivateKey(_registrationData.keys['privateKey']);
    savePublicKey(_registrationData.keys['publicKey']);
    saveFingerprint(false);
    saveEmail(_registrationData.email, null);
    saveDoubleName(_registrationData.doubleName.toLowerCase());
    savePhrase(_registrationData.phrase);

    await sendVerificationEmail();
  }

  loadingDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 10,
            ),
            new CircularProgressIndicator(),
            SizedBox(
              height: 10,
            ),
            new Text("Loading"),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget registrationStepper() {
    return Theme(
      data: ThemeData(
        primaryColor: Globals.color,
        accentColor: Globals.color,
      ),
      child: Stepper(
        controlsBuilder: (BuildContext context,
            {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
          return Column(
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  FlatButton(
                    onPressed: () {
                      onStepCancel();
                    },
                    child: Text(
                      state == _State.DoubleName ? 'CANCEL' : 'PREVIOUS',
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Theme.of(context).accentColor,
                  ),
                  FlatButton(
                    onPressed: () {
                      onStepContinue();
                    },
                    child: Text(
                      state == _State.Finish ? 'FINISH' : 'NEXT',
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Theme.of(context).accentColor,
                  )
                ],
              ),
            ],
          );
        },
        type: StepperType.vertical,
        steps: [
          Step(
            // Ask DoubleName
            isActive: state.index >= _State.DoubleName.index,
            state: state.index > _State.DoubleName.index
                ? StepState.complete
                : state == _State.DoubleName
                    ? StepState.editing
                    : StepState.disabled,
            title: Text('3Bot name'),
            subtitle: state.index > 0 ? Text(doubleNameController.text) : null,
            content: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Hi, please choose a 3Bot name.',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Divider(
                      height: 50,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.5),
                      child: TextFormField(
                        focusNode: nameFocus,
                        maxLength: 50,
                        autofocus: true,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Name',
                          suffixText: '.3bot',
                          suffixStyle: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        controller: doubleNameController,
                        inputFormatters: <TextInputFormatter>[
                          WhitelistingTextInputFormatter(RegExp("[a-zA-Z0-9]"))
                        ],
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text(
                            errorStepperText,
                            style: TextStyle(color: Colors.red),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      height: 50,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Step(
            isActive: state.index >= _State.Email.index,
            state: state.index > _State.Email.index
                ? StepState.complete
                : state == _State.Email
                    ? StepState.editing
                    : StepState.disabled,
            title: Text('Email'),
            subtitle: state.index > _State.Email.index
                ? Text(emailController.text)
                : null,
            content: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ReuseableTextFieldStep(
                  focusNode: emailFocus,
                  titleText: 'What is your email?',
                  labelText: 'Email',
                  typeText: TextInputType.emailAddress,
                  errorStepperText: errorStepperText,
                  controller: emailController,
                ),
              ),
            ),
          ),
          Step(
            isActive: state.index >= _State.SeedPhrase.index,
            state: state.index > _State.SeedPhrase.index
                ? StepState.complete
                : state == _State.SeedPhrase
                    ? StepState.editing
                    : StepState.disabled,
            title: Text('Seed phrase'),
            content: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ReuseableTextStep(
                  titleText:
                      'Please write this on a piece of paper and keep it in a secure place.',
                  extraText: _registrationData.phrase,
                  errorStepperText: errorStepperText,
                ),
              ),
            ),
          ),
          Step(
            isActive: state.index >= _State.ConfirmSeedPhrase.index,
            state: state.index > _State.ConfirmSeedPhrase.index
                ? StepState.complete
                : state == _State.ConfirmSeedPhrase
                    ? StepState.editing
                    : StepState.disabled,
            title: Text('Confirm seed phrase'),
            content: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ReuseableTextFieldStep(
                  focusNode: seedFocus,
                  titleText:
                      'Type 3 random words from your seed phrase, separated by a space.',
                  labelText: 'Seed phrase words',
                  typeText: TextInputType.text,
                  errorStepperText: errorStepperText,
                  controller: seedConfirmationController,
                ),
              ),
            ),
          ),
          Step(
            isActive: state.index >= _State.Finish.index,
            state: state.index > _State.Finish.index
                ? StepState.complete
                : state == _State.Finish
                    ? StepState.editing
                    : StepState.disabled,
            title: Text('Finishing'),
            content: Card(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 10.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Please check the data below, press finish if it is correct. Otherwise click the pencil icon to edit them.',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                    child: ListTile(
                      leading: Icon(Icons.person),
                      title: Text(doubleNameController.text),
                      trailing: Icon(Icons.edit),
                      onTap: () => setState(() {
                        state = _State.DoubleName;
                        FocusScope.of(context).requestFocus(nameFocus);
                      }),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0, bottom: 15.0),
                    child: ListTile(
                        leading: Icon(Icons.email),
                        title: Text(emailController.text),
                        trailing: Icon(Icons.edit),
                        onTap: () => setState(() {
                              state = _State.Email;
                              FocusScope.of(context).requestFocus(emailFocus);
                            })),
                  ),
                ],
              ),
            ),
          )
        ],
        currentStep: state.index,
        onStepTapped: (index) {
          setState(() {
            state = _State.values[index];
          });
          checkStepFocus(state);
        },
        onStepContinue: () {
          errorStepperText = '';
          checkStep(state);
        },
        onStepCancel: () {
          setState(
            () {
              errorStepperText = '';
              if (state.index > _State.DoubleName.index) {
                state = _State.values[state.index - 1];
              } else {
                Navigator.pop(context);
              }
            },
          );
          checkStepFocus(state);
        },
      ),
    );
  }

  Widget errorWidget() {
    return errorStepperText.isNotEmpty
        ? Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  errorStepperText,
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          )
        : Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Globals.color,
        title: Text('3Bot Connect - Registration'),
      ),
      body: registrationStepper(),
    );
  }
}
