import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/addCommission.dart';
import 'package:flutter_application_1/addNewCommission.dart';
import 'package:flutter_application_1/addService.dart';
import 'package:flutter_application_1/adminEmployees.dart';
import 'package:flutter_application_1/data.dart';
import 'package:flutter_application_1/database.dart';
import 'package:flutter_application_1/listPages.dart';
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
    list = PaymentListPage(employee: widget.employee.employeeInfo.email);
    
  }

  Widget? list;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Color(0xff444444),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Payments'),
        actions: [
          
        ],
      ),
      body: Center(
        child: Container(
        width: 450,
          color: Colors.white,
          child: Column (
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: list!) ,
              
            ],
          ),
        )  
      )  // This trailing comma makes auto-formatting nicer for build methods.
      
    );
  }
}
