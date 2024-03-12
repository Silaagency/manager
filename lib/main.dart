import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/adminMain.dart';
import 'package:flutter_application_1/database.dart';
import 'package:flutter_application_1/employeeMain.dart';
import 'package:flutter_application_1/register.dart';
import 'constants.dart';
import 'data.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Log in'),
      
      navigatorObservers: <NavigatorObserver>[routeObserver],
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String sessionLoginState = "waiting";
  Employee? employee;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loginWithId().then((value) {
      setState(() {
        sessionLoginState = value.$2;
      });
      if (value.$2 == "admin") {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminMainPage()));
      } else if (value.$2 == "employee") {
        Navigator.push(context, MaterialPageRoute(builder: (context) => EmployeeMainPage(employee: employee!)));
      } else {
        setState(() {
          sessionLoginState = "failed";
        });
      }
    });
  }


  Future<void> processInput() async
  {
    try {
      await login(emailController.text, passwordController.text).then((value) {
        showToast("login succesful", context: context, position: StyledToastPosition.top);
        if (value.$2 == "employee") {
          Employee emp = value.$1;
          Navigator.push(context, MaterialPageRoute(builder: (context) => EmployeeMainPage(employee: emp)));;

        } else if (value.$2 == "admin")
        {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminMainPage()));
        }
      });

    } catch(e) {
      showToast(e.toString(), context:context, position: StyledToastPosition.top);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Color(0xff444444),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Card(
          color: AppColors.backgroundColor,
          elevation: 5,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: (sessionLoginState == "waiting") ? CircularProgressIndicator() : Container(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 400,
                  child:  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 40),
                      SizedBox( 
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            processInput();
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(AppColors.primaryColor)
                            
                          ),
                          child: const Text('Log in'), // Button text
                        ),
                      )
                      ,
                      const SizedBox(height: 20),
                      Container( 
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage()));
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(AppColors.primaryColor)  
                          ),
                          child: const Text('Register'), // Button text
                        ),
                      )
                    ],
                  ),
                ),
              )
            ) 
          )
        ),
      )
    ); // This trailing comma makes auto-formatting nicer for build methods.
  }
}
