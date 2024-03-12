import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/addService.dart';
import 'package:flutter_application_1/adminEmployees.dart';
import 'package:flutter_application_1/commercial.dart';
import 'package:flutter_application_1/data.dart';
import 'package:flutter_application_1/database.dart';
import 'package:flutter_application_1/service.dart';
import 'constants.dart';

class AdminMainPage extends StatefulWidget {
  const AdminMainPage({super.key});

  @override
  State<AdminMainPage> createState() => _AdminMainPageState();
}

class _AdminMainPageState extends State<AdminMainPage> with RouteAware  {
  List<String> serviceNames = List.empty(growable: true);


 @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  // Called when the top route has been popped off, and the current route shows up.
  void didPopNext() {
    updateState();
  }

  @override
  void initState() {
    super.initState();
    updateState();
  }

  void updateState()
  {
    fetchServices().then((value) => {setState(() {
      serviceNames = value.map((e) => e.name).toList(); 
    })});
    
  }

  void processInput()
  {

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff444444),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Main Menu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AddServicePage()));
            },
          ),
        ],
      ),
      body: Center(
        child: Card(
          color: AppColors.backgroundColor,
          child: Padding(
            padding: EdgeInsets.only(top: 20, bottom: 20, right: 10, left: 10),
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 400,
                  child:  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminEmployeesPage()));
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(AppColors.primaryColor)  
                          ),
                          child: const Text('Employés', style: TextStyle(fontSize: 20)), // Button text
                        ),
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => CommercialPage()));
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(AppColors.primaryColor)  
                          ),
                          child: const Text('Commercial', style: TextStyle(fontSize: 20)), // Button text
                        ),
                      ),
                      ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: serviceNames.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => ServicePage(service: serviceNames[index])));
                                },
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(AppColors.primaryColor)  
                                ),
                                child: Text(serviceNames[index], style: TextStyle(fontSize: 20)), // Button text
                              ),
                            )
                          );
                        },
                      ),
                    ],
                  ),
                ),
              )
            ) 
          ),
        )
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
