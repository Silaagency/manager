import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:Manager/addCommission.dart';
import 'package:Manager/addNewCommission.dart';
import 'package:Manager/addService.dart';
import 'package:Manager/adminEmployees.dart';
import 'package:Manager/data.dart';
import 'package:Manager/database.dart';
import 'package:Manager/listPages.dart';
import 'constants.dart';
import 'adminEmployeeDetails.dart';
import 'data.dart';


class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key, required this.employee});

  final Employee employee;

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> with RouteAware  {
  

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

  }

  void processInput()
  {

  }
  
  @override
  void initState() {
    super.initState();
    list = [
      PaymentListPage(employee: widget.employee.employeeInfo.email),
      VersementListPage(employee: widget.employee.employeeInfo.email)
    ];
    
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  List<Widget>? list;
  int _selectedIndex = 0;
  final PageStorageBucket _bucket = PageStorageBucket();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.zeroColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Payments'),
        actions: [
          
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.payments_rounded), 
            label: 'Payments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payments_outlined),
            label: 'Versements',
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
            children: list!.map((Widget widget) {
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
