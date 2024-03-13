import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:Manager/addService.dart';
import 'package:Manager/adminEmployees.dart';
import 'package:Manager/commercial.dart';
import 'package:Manager/data.dart';
import 'package:Manager/database.dart';
import 'package:Manager/service.dart';
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
      backgroundColor: AppColors.zeroColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Menu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
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
                          child: Text('Employés', style: defaultTextStyle), // Button text
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
                          child: Text('Commercial', style: defaultTextStyle), // Button text
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
                                child: Text(serviceNames[index], style: defaultTextStyle), // Button text
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
