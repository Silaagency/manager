import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:Manager/addEmployee.dart';
import 'package:Manager/addService.dart';
import 'package:Manager/adminEmployeeDetails.dart';
import 'package:Manager/data.dart';
import 'constants.dart';
import 'listPages.dart';



class AdminEmployeesPage extends StatefulWidget {
  const AdminEmployeesPage({super.key});

  @override
  State<AdminEmployeesPage> createState() => _AdminEmployeesPageState();
}

class _AdminEmployeesPageState extends State<AdminEmployeesPage> with RouteAware  {
  

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

  void updateState()
  {
    setState(() {
      (_widgetOptions[0] as EmployeeListPage).updateData();
      (_widgetOptions[1] as EmployeeListPage).updateData();
    });
  }

  void processInput()
  {

  }

  int _selectedIndex = 0;
  final PageStorageBucket _bucket = PageStorageBucket();



  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

    static List<Widget> _widgetOptions = <Widget>[
    EmployeeListPage(isNew: false), // Example widget for the Home Page
    EmployeeListPage(isNew: true), // Example widget for the Search Page
  ];


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.zeroColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Employés'),
      ),
      bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home), 
              label: 'Tous',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Nouveaux',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue,
          onTap: _onItemTapped,
        ),
      body: Center(
        child: Container(
          height: double.infinity,
          color: AppColors.backgroundColor,
          child: IndexedStack(
            index: _selectedIndex,
            children: _widgetOptions.map((Widget widget) {
              return PageStorage(
                key: PageStorageKey(widget),
                bucket: _bucket,
                child: widget,
              );
            }).toList(),
          ) 
        ), 
      )  // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}


