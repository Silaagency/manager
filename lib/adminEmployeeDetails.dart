import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:Manager/addEmployee.dart';
import 'package:Manager/addService.dart';
import 'package:Manager/adminEmployees.dart';
import 'package:Manager/data.dart';
import 'package:Manager/database.dart';
import 'package:Manager/listPages.dart';
import 'package:Manager/payments.dart';
import 'constants.dart';


class AdminEmployeeDetailsPage extends StatefulWidget {
  const AdminEmployeeDetailsPage({super.key, required this.employee});

  final EmployeeInfo employee;

  @override
  State<AdminEmployeeDetailsPage> createState() => _AdminEmployeeDetailsPageState();
}

class _AdminEmployeeDetailsPageState extends State<AdminEmployeeDetailsPage> with RouteAware  {

  Employee? employee;

  
  TextEditingController absenceController = TextEditingController();

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

      fetchEmployeeByEmail(widget.employee.email).then((value) {
        setState(() {
          employee = value;

          absenceController.text = employee!.paymentInfo.absence.toString();
      
          calculateSalary(employee! , DateTime.now()).then((value)  {
            setState(() {
              salary = value.$1;
            });
          });

        });
      });

      if (widget.employee.service == "Commercial")
        (list! as NewCommissionListPage). updateData();
      else
        (list! as CommissionListPage). updateData();


    });
  }

  void processInput()
  {

  }

  void verser(int amount, String comment)
  {
    Payment payment = Payment(employee: employee!.employeeInfo.email, comment: comment, date: DateTime.now(), amount: amount);
    createPayment(payment).then((value) => updateState());
  }

  @override
  void initState() {
    super.initState();
    
    if (widget.employee.service == "Commercial")
      list = NewCommissionListPage(filter: widget.employee.email);

    else
      list = CommissionListPage(isService: false, filter: widget.employee.email);

    fetchEmployeeByEmail(widget.employee.email).then((value) {
      setState(() {
        employee = value;

        absenceController.text = employee!.paymentInfo.absence.toString();
    
        calculateSalary(employee! , DateTime.now()).then((value)  {
          setState(() {
            salary = value.$1;
          });
        });
      });
    });

  }

  FilteredList? list;

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
      penalty = (res / 30 * int.parse(absenceController.text) ).round();
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

  Future<void> performPayment() async {
    final payment = (await calculateSalary(employee!, DateTime.now())).$2;

    createFinalPayment(
      FinalPayment(
        employee: employee!.employeeInfo.email,
        date: DateTime.now(),
        amount: payment.payed,
        details: payment
      )
    ).then((value) => updateState());
  }

  void _handlePayButtonPressed() {
    final now = DateTime.now();
    if (now.day != 1) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirmer le payment'),
            content: Text('Êtes-vous sûr de vouloir procéder au paiement?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Annuler'),
              ),
              TextButton(
                onPressed:  () async{
                  await performPayment();
                  Navigator.pop(context);
                },
                child: Text('Confirmer'),
              ),
            ],
          );
        },
      );
    } else {
      performPayment();
    }
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.zeroColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Employee"),
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
            icon: const Icon(Icons.payment),
            tooltip: 'Pay',
            onPressed: _handlePayButtonPressed,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AddEmployeePage(employee: employee?.employeeInfo??widget.employee, op: Operation.Edit)));
            },
          ),
        ],
        
      ),
      
      body: Center(
        child: Container( 
        width: 450,
          color: Colors.white,
          child: Column (
            mainAxisSize: MainAxisSize.min,
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: (list as Widget?)!),
              Card(
                elevation: 3,
                child: Container(
                  color: AppColors.backgroundColor3,
                  height: 120,
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          child: Container (
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

                          ),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentPage(employee: employee!)));
                          },
                        )
                      ),
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.only(left: 40, right: 40),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container( 
                                  height: 40,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          TextEditingController versementController = TextEditingController();
                                          TextEditingController commentController = TextEditingController();
                                          return AlertDialog(
                                            title: Text('Versement'),
                                            content: Container(
                                              width: 200,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  TextField(
                                                    keyboardType: TextInputType.number,
                                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                                    controller: versementController,
                                                    decoration: InputDecoration(
                                                      hintText: 'Entrer le montant',
                                                      suffixText: 'DA',
                                                    ),
                                                  ),
                                                  TextField(
                                                    controller: commentController,
                                                    decoration: InputDecoration(
                                                      hintText: 'Commentaire',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            
                                            actions: [
                                              TextButton(
                                                child: Text('Annuler'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              TextButton(
                                                child: Text('Confirmer'),
                                                onPressed: () {
                                                  final text = versementController.text;
                                                  final comment = commentController.text;
                                                  int res = 0;
                                                  if (text != "")
                                                    res = int.parse(text);
                                                  Navigator.of(context).pop((res, "fezfez"));
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      ).then((value) {
                                        if (value != null && value != 0) {
                                          verser(value.$1, value.$2);
                                        }
                                      });
                                    },
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all<Color>(AppColors.primaryColor)  
                                    ),
                                    child: Text(
                                      'Verser',
                                      style: defaultTextStyle,
                                    ), // Button text
                                  ),
                                ),
                                Visibility(
                                  visible: employee?.paymentInfo.penalizedAbsence ?? false,
                                  child: SizedBox(height: 10,),
                                ),
                                Visibility(
                                  visible: employee?.paymentInfo.penalizedAbsence ?? false,
                                  child: Container( 
                                    height: 40,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            
                                            return AlertDialog(
                                              title: Text('Absence'),
                                              content: TextField(
                                                keyboardType: TextInputType.number,
                                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                                controller: absenceController,
                                                decoration: InputDecoration(
                                                  hintText: 'Entrer le nombre de jour',
                                                  suffixText: 'jour',
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  child: Text('Annuler'),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                TextButton(
                                                  child: Text('Confirmer'),
                                                  onPressed: () {
                                                    
                                                    if (employee != null) {
                                                      Employee emp = employee!;
                                                      emp!.paymentInfo!.absence = int.parse(absenceController.text);
                                                      updateEmployee(employee!.employeeInfo.email, emp).then((value) {updateState();});
                                                    }
                                                    //TO DO: modify the number of absence in DATA!
                                                    
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all<Color>(AppColors.primaryColor)  
                                      ),
                                      child: FittedBox(
                                        fit: BoxFit.fitWidth,
                                        child: Text(
                                          'Absence (' + (employee?.paymentInfo.absence.toString() ?? '0') + ')', style: defaultTextStyle
                                        ),
                                      )
                                    ),
                                  ),
                                ),
                              ],
                            )
                          )
                        )
                      ),
                    ],
                  ),
                )
              )
            ],
          ),
        )  
      )
    );
  }
}


class FiltersDialog extends StatefulWidget {
  FiltersDialog({required this.list});

  final FilteredList list;

  @override
  _FiltersDialogState createState() => _FiltersDialogState();
}

class _FiltersDialogState extends State<FiltersDialog> {
  bool _nonPayed = false;
  bool _canceled = false;
  bool _payed = false;

  @override
  void initState() {
    super.initState();

    Filter f = widget.list.getFilter()??Filter();
    _nonPayed = f.notPayed;
    _canceled = f.canceled;
    _payed = f.payed;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Container (
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Filters',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.0),
              CheckboxListTile(
                title: Text('Non payé'),
                value: _nonPayed,
                onChanged: (value) {
                  setState(() {
                    _nonPayed = value!;
                  });
                },
              ),
              CheckboxListTile(
                title: Text('Annulé'),
                value: _canceled,
                onChanged: (value) {
                  setState(() {
                    _canceled = value!;
                  });
                },
              ),
              CheckboxListTile(
                title: Text('Payé'),
                value: _payed,
                onChanged: (value) {
                  setState(() {
                    _payed = value!;
                  });
                },
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      widget.list.setFilter(Filter(notPayed: _nonPayed, canceled: _canceled, payed: _payed));
                      Navigator.of(context).pop();
                    },
                    child: Text('Save'),
                  ),
                ],
              ),
            ],
          ),   
        )
      ),
    );
  }
}