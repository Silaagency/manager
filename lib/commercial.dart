import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:Manager/addEmployee.dart';
import 'package:Manager/addService.dart';
import 'package:Manager/adminEmployeeDetails.dart';
import 'package:Manager/data.dart';
import 'constants.dart';
import 'listPages.dart';



class CommercialPage extends StatefulWidget {
  const CommercialPage({super.key, this.filter});

  final String? filter;

  @override
  State<CommercialPage> createState() => _CommercialPageState();
}

class _CommercialPageState extends State<CommercialPage> with RouteAware  {

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
      (_widgetOptions[1] as NewCommissionListPage).updateData();
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

  List<Widget> _widgetOptions = List.empty();

  @override
  void initState() {
    super.initState();

    _widgetOptions = <Widget>[
      EmployeeListPage(isNew: false, filter: "Commercial"), // Example widget for the Home Page
      NewCommissionListPage(filter: widget.filter), // Example widget for the Search Page
    ];
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.zeroColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Employees'),
      ),
      bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home), 
              label: 'Employees',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Commissions',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue,
          onTap: _onItemTapped,
        ),
      body: Center(
        child: Container(
          width: 450,
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
          ),
         )
       ) // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}


