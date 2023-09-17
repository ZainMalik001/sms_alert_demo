import 'dart:async';

import 'package:background_sms/background_sms.dart';
import 'package:flutter/material.dart';
import 'package:open_settings/open_settings.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sms_demo/models/get_task_model.dart';

import 'package:sms_demo/models/model_login.dart';
import 'package:sms_demo/util/local_base.dart';
import 'package:sms_demo/web_service/servicewrapper.dart';

class SignIn extends StatefulWidget {
  SignIn({Key? key}) : super(key: key);
  var allSIM = ['SIM 1', 'SIM 2'];
  String selSIM = 'SIM 1';
  bool loading = false;
  bool needToLogin = true;
  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _formKey = GlobalKey<FormState>();
  bool loginDone = false;
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  dynamic token;

  _logIn(BuildContext context) async {
    Servicewrapper wrapper = new Servicewrapper();

    if (!(await _isPermissionGranted())) await _getPermission();
    if (!(await _isPermissionGranted())) {
      wrapper.showErrorMsg('Permission denied');
      return;
    }
    var res = await wrapper.logIn(
      usernameController.text,
      passwordController.text,
    );

    if (res == null) return;

    final Map<String, dynamic> parsed = res;
    usr = ModelLogin.fromJson(parsed);
    LocalRepo().setToken(usr?.accessToken ?? '');
    if (usr?.accessToken != '' && usr?.accessToken != null) {
      setState(() {
        widget.needToLogin = false;
      });
    } else {
      setState(() {
        widget.needToLogin = true;
      });
    }
    loginDone = true;
  }

  _updateTaskUser(int taskID) async {
    Servicewrapper wrapper = new Servicewrapper();
    var res = await wrapper.updateTaskUser(taskID);
    if (res == null) return;
  }

  _checkUserLogged() async {
    setState(() {
      widget.loading = true;
    });

    try {
      token = await LocalRepo().getToken();
      if (token == null || token == '') {
        widget.needToLogin = true;
      } else {
        usr = ModelLogin(accessToken: token);
        Servicewrapper wrapper = new Servicewrapper();
        var res = await wrapper.userDetails();
        if (res == null) {
          widget.needToLogin = true;
        } else {
          final Map<String, dynamic> parsed = res;
          usr?.id = parsed['id'];
          usr?.username = parsed['username'];
        }

        if (usr?.id == null) {
          widget.needToLogin = true;
        } else {
          widget.needToLogin = false;
        }
      }
    } on Exception {}
    setState(() {
      widget.loading = false;
    });
  }

  Future<void> getSmsTask() async {
    Servicewrapper wrapper = new Servicewrapper();
    var res = await wrapper.getSmsTask();
    if (res == null) return;
    final Map<String, dynamic> parsed = res;
    GetTaskModel model = GetTaskModel.fromJson(parsed);

    if (model.smsTask?.toNumber != '' && model.smsTask?.message != '') {
      await _sendSMSMsgs(model.smsTask?.message ?? '', model.smsTask?.toNumber ?? '', model.smsTask?.taskId ?? 0);
    }
  }

  _getPermission() async => await [
        Permission.sms,
      ].request();
  Future<bool> _isPermissionGranted() async => await Permission.sms.status.isGranted;
  Future<bool?> get _supportCustomSim async => await BackgroundSms.isSupportCustomSim;

  _sendSMSMsgs(String message, String number, taskId) async {
    Servicewrapper wrapper = new Servicewrapper();
    int? simSlot;
    bool sendingFailed = false;

    if ((await _supportCustomSim)!) {
      simSlot = 1;
      if (widget.selSIM == widget.allSIM[1]) simSlot = 2;
    }

    var result = await BackgroundSms.sendMessage(
      phoneNumber: number,
      message: message,
      simSlot: simSlot,
    );
    if (result == SmsStatus.sent) {
      await _updateTaskUser(taskId ?? 0);
    } else {
      sendingFailed = true;
    }

    if (sendingFailed) wrapper.showErrorMsg('SMS sending failed');
  }

  Future<bool> _onWillPop() async {
    return false;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkUserLogged();
    Timer.periodic(Duration(seconds: 3), (timer) {
      if (!widget.needToLogin) {
        getSmsTask();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text('Sign In'),
        ),
        body: widget.loading
            ? Center(child: CircularProgressIndicator())
            : SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Form(
                    key: _formKey,
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            widget.needToLogin
                                ? Column(
                                    children: [
                                      TextFormField(
                                        controller: usernameController,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText: 'Username',
                                        ),
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return "Enter your username";
                                          } else {
                                            return null;
                                          }
                                        },
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      TextFormField(
                                        controller: passwordController,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText: 'Password',
                                        ),
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return "Enter correct password";
                                          } else {
                                            return null;
                                          }
                                        },
                                        obscureText: true,
                                      ),
                                    ],
                                  )
                                : Center(
                                    child: Text(
                                      'Hello ${usr?.username ?? ''}',
                                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                            SizedBox(
                              height: 30,
                            ),
                            LoginButton(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
        floatingActionButton: widget.needToLogin
            ? null
            : GestureDetector(
                onTap: () async {
                  OpenSettings.openManageDefaultAppsSetting();
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Open Settings',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ), //
      ),
    );
  }

  ElevatedButton LoginButton() {
    return ElevatedButton(
        onPressed: widget.needToLogin
            ? () async {
                if (_formKey.currentState!.validate()) {
                  try {
                    await _logIn(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        margin: EdgeInsets.only(bottom: 20),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.red,
                        content: Text(e.toString())));
                  }
                }
              }
            : () {
                setState(() {
                  LocalRepo().deleteToken();
                  usr?.accessToken = "";
                  usernameController.clear();
                  passwordController.clear();
                  widget.needToLogin = true;
                });
              },
        child: widget.needToLogin ? Text('SignIn') : Text('SignOut'));
  }
}
