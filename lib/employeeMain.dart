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
import 'package:flutter_application_1/payments.dart';
import 'constants.dart';
import 'adminEmployeeDetails.dart';
import 'data.dart';


class EmployeeMainPage extends StatefulWidget {
  const EmployeeMainPage({super.key, required this.employee});

  final Employee employee;

  @override
  State<EmployeeMainPage> createState() => _EmployeeMainPageState();
}

class _EmployeeMainPageState extends State<EmployeeMainPage> with RouteAware  {
  

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
      if (widget.employee.employeeInfo.service == "Commercial")
        (list! as NewCommissionListPage). updateData();
      else
        (list! as CommissionListPage). updateData();

      calculateSalary(widget.employee , DateTime.now()).then((value)  {
        setState(() {
          salary = value.$1;
        });
      });
    });
  }

  void processInput()
  {

  }

  int salary = 0;

  Future<(int, PaymentDetails)> calculateSalary(Employee employee, DateTime date) async {
    int salary = 0;
    int commissionsPay = 0;
    int prepaid = 0;
    int penalty = 0;
    int res = 0;

    if (employee.paymentInfo.hasSalary)
    {
      salary = employee.paymentInfo.salary;
      res += salary;
    }


    if (employee.paymentInfo.penalizedAbsence)
    {
      penalty = (res / 30 * employee.paymentInfo.absence).round();
      res -= penalty;
    }
    

    if (employee.paymentInfo.paidCommissions)
    {
      if (employee.employeeInfo.service == "Commercial")
      {
        final commissions = await getNewCommissions(filters: {"employee" : employee.employeeInfo.email});
          for (NewCommission com in commissions)
          {
            if (com.status == Status.notPayed)
              commissionsPay += com.project.pay;
          }
          res += commissionsPay;
      }
      else
      {
        final commissions = await getCommissions(filters: {"employee" : employee.employeeInfo.email});
        for (Commission com in commissions)
        {
          if (com.status == Status.notPayed)
            commissionsPay += com.project.pay;
        }
        res += commissionsPay;
      }
    }

    final lastPayment = await getLatestFinalPayment(filters: {"employee" : employee.employeeInfo.email});


    final payments = await getPayments(filters: {"employee" : employee.employeeInfo.email, "dateFrom" : lastPayment?.date.toIso8601String()?? DateTime(2024).toIso8601String()});
    for (Payment pay in payments)
    {
      prepaid += pay.amount;
    }
    res -= prepaid;

    return (res, PaymentDetails(salary: salary, commissions: commissionsPay, penalty: penalty, prepaid: prepaid, payed: res));
  }


  @override
  void initState() {
    super.initState();
    
    if (widget.employee.employeeInfo.service == "Commercial")
      list = NewCommissionListPage(filter: widget.employee.employeeInfo.email);
    else
      list = CommissionListPage(isService: false, filter: widget.employee.employeeInfo.email);

      calculateSalary(widget.employee , DateTime.now()).then((value)  {
        setState(() {
          salary = value.$1;
        });
      });
  }

  FilteredList? list;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.zeroColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Employé'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_rounded),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return FiltersDialog(list: list!);
                },
              );
            }
          ), 
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              if (widget.employee.employeeInfo.service == "Commercial") 
                Navigator.push(context, MaterialPageRoute(builder: (context) => AddNewCommissionPage(employee: widget.employee)));
              else
                Navigator.push(context, MaterialPageRoute(builder: (context) => AddCommissionPage(employee: widget.employee)));

            },
          ),
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
              Expanded(child: (list as Widget?)!) ,
              Card(
                elevation: 3,
                child: Container(
                  color: AppColors.backgroundColor3,
                  height: 100,
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Salaire"),
                                Text(
                                salary.toString() + " DA",
                                style: TextStyle(fontSize: 30),
                                ),
                              ],
                            )
                          ),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentPage(employee: widget.employee)));
                          },
                        )
                      ),
                    ],
                  ),
                )
              )
            ],
          ),
        )  
      )  // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
