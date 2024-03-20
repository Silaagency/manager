import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:Manager/addService.dart';
import 'package:Manager/adminEmployees.dart';
import 'package:Manager/data.dart';
import 'package:Manager/database.dart';
import 'constants.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';



class AddEmployeePage extends StatefulWidget {
  const AddEmployeePage({super.key, required this.employee, required this.op});

  final EmployeeInfo employee;
  final Operation op;

  @override
  State<AddEmployeePage> createState() => _AddEmployeePageState();


}


class _AddEmployeePageState extends State<AddEmployeePage> with RouteAware  {

 Employee? employee;

  @override
  void initState() {
    super.initState();

    if (widget.op == Operation.Edit)
    {
      fetchEmployeeByEmail(widget.employee.email).then((value) {
        setState(() {
          employee = value;
          hasSalary = employee!.paymentInfo.hasSalary;
          paidCommissions = employee!.paymentInfo.paidCommissions;
          penalizedAbsence = employee!.paymentInfo.penalizedAbsence;
          salaryController.text = employee!.paymentInfo.salary.toString();
        });
      });
      
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  bool hasSalary = false;
  bool paidCommissions = false;
  bool penalizedAbsence = false;

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
    int salary = 0;
   
    setState(() {
      savePressed = true;
    });

    if (hasSalary)
    {
      if (salaryController.text.isNotEmpty) {
        salary = int.parse(salaryController.text);
      }
      else return;
        
    } else if (!paidCommissions)
    {
      // print toast
      showToast("You must choose a payment method", context:context);

      return;
    }
    
    Employee emp = Employee(
      employeeInfo: widget.employee,
      paymentInfo: PaymentInfo(
        hasSalary: hasSalary,
        paidCommissions: paidCommissions,
        penalizedAbsence: true,
        salary: salary,
        absence: employee?.paymentInfo.absence??0
    ));

    // add employee
    if (widget.op == Operation.Add)
    {
      confirmEmployee(emp).then((value) => Navigator.pop(context));
    }
    else
    {
      updateEmployee(employee!.employeeInfo.email, emp).then((value) => Navigator.pop(context));
    }


    return;
  }
  
  TextEditingController salaryController = TextEditingController();

  bool savePressed = false;
  
  String? getGenericError(TextEditingController controller){
    if (!savePressed) return null;
    else
    {
      if (controller.text.isEmpty) return "This field Cannot be left Empty";

      else
      {
        return null;
      } 
    }
  }
  
  Future<void> _handleDeleteButtonPressed() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmer'),
          content: Text('Êtes-vous sûr de vouloir suprimer cet employee?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                await deleteEmployeeByEmail(widget.employee.email);
                Navigator.pop(context);
              },
              child: Text('Confirmer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.zeroColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("New Employee"),
        actions: (widget.op == Operation.Add)?null:[
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Suprimer',
            onPressed: () async {
              await _handleDeleteButtonPressed();
              Navigator.pop(context, "deleted");
            },
          ),
        ],
      ),
      body: Center(
        child: Container(
          width: 450,
          child: Card(
            elevation: 5,
            child: SingleChildScrollView(
              child: Center(
                child: Container(
                  //color: AppColors.backgroundColor,
                  child: Padding(
                    padding: const EdgeInsets.only( right: 20, left: 20, top: 20, bottom: 20),
                    child: Container(
                      //color: AppColors.backgroundColor2,
                      width: 400,
                      child:  Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(left: 60, top: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  child: Text(
                                    "Nom",
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                  ) 
                                ),
                                SizedBox(
                                  child: Text(
                                    widget.employee.name,
                                    style: TextStyle(fontSize: 20),
                                  ) 
                                ),
                                SizedBox(height: 20,),
                                const SizedBox(
                                  child: Text(
                                    "Email",
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                SizedBox(
                                  child: Text(
                                    widget.employee.email,
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                                SizedBox(height: 20,),
                                const SizedBox(
                                  child: Text(
                                    "Numéro de téléphone",
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                SizedBox(
                                  child: Text(
                                    widget.employee.phone,
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                                SizedBox(height: 20,),
                                const SizedBox(
                                  child: Text(
                                    "Service",
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                SizedBox(
                                  child: Text(
                                    widget.employee.service,
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                              ],
                            ), 
                          ),
                          const SizedBox(height: 40,),
                          Center(
                            child: SizedBox(
                              width: 300,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  CheckboxListTile(
                                    title: const Text('Paid for commissions'),
                                    value: paidCommissions,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        paidCommissions = value!;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 10,),
                                  CheckboxListTile(
                                    title: const Text('Salaire'),
                                    value: hasSalary,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        hasSalary = value!;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 20,),
                                  Visibility(
                                    visible: hasSalary,
                                    child:  TextField(
                                      controller: salaryController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                      decoration: InputDecoration(
                                        labelText: 'Salaire',
                                        suffix: const Text('DA'),
                                        border: const OutlineInputBorder(),
                                        errorText: hasSalary? getGenericError(salaryController): null,
                                    ),
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
                                      child: const Text('Confirm'), // Button text
                                    ),
                                  )
                                ],
                              )
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ) 
              ), 
            ),
          ),
        )   
      )
    );
  }
}