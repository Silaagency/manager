import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:Manager/addEmployee.dart';
import 'package:Manager/addService.dart';
import 'package:Manager/adminEmployeeDetails.dart';
import 'package:Manager/data.dart';
import 'package:Manager/database.dart';
import 'constants.dart';
import 'listPages.dart';



class ServicePage extends StatefulWidget {
  const ServicePage({super.key, required this.service});

  final String service;
  
  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> with RouteAware  {

  Service? service;

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

  }

  void updateState()
  {
    setState(() {
      fetchServiceByName(service?.name ?? widget.service).then((value) => { service = value});
      (_widgetOptions[0] as EmployeeListPage).updateData();
      (_widgetOptions[1] as CommissionListPage).updateData();
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
      EmployeeListPage(isNew: false, filter: widget.service), // Example widget for the Home Page
      CommissionListPage(isService: true, filter: widget.service), // Example widget for the Search Page
    ];

    fetchServiceByName(service?.name ?? widget.service).then((value) => { service = value});
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.zeroColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text( service?.name ?? widget.service),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddServicePage(service: service,)));
              service!.name = result;
              updateState();
            },
          ),
        ],
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
      ) // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}


