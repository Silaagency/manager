import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/data.dart';
import 'package:flutter_application_1/database.dart';
import 'constants.dart';


class AddNewCommissionPage extends StatefulWidget {
  const AddNewCommissionPage({super.key, required this.employee});

  final Employee employee;

  @override
  State<AddNewCommissionPage> createState() => _AddNewCommissionPageState();
}

class _AddNewCommissionPageState extends State<AddNewCommissionPage> {

  String? _selectedItem;
  List<String> serviceNames = List.empty(growable: true);
  List<Service> services = List.empty(growable: true);
  int montant = 0;

  @override
  void initState() {
    fetchServices().then((value) {
      setState(() {
        services.addAll(value);
        serviceNames.addAll(value.map((e) => e.name));
      });
    });
  }


  TextEditingController clientNameController = TextEditingController();
  TextEditingController clientNumberController = TextEditingController();
  TextEditingController projectNameController = TextEditingController();
  TextEditingController factureNumberController = TextEditingController();

  List<List<TextEditingController>> textControllers = [];
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

  String? getServicesError(){
    if (!savePressed) return null;
    if (_selectedItem == null)
      return "You must select a service";
    return null;
  }

  void processInput()
  {
    int fieldCount = 5;
    int validFields = 0;
    setState(() {
      savePressed = true;
    });

    if (!clientNameController.text.isEmpty){
      validFields++;
    }

    if (!clientNumberController.text.isEmpty){
      validFields++;
    }

    if (!projectNameController.text.isEmpty){
      validFields++;
    }

    if (!factureNumberController.text.isEmpty){
      validFields++;
    }

    if (_selectedItem != null)
      validFields++;

    if (validFields == fieldCount){
      // form is valid

      String clientName = clientNameController.text;
      String clientNumber = clientNumberController.text;
      String projectName = projectNameController.text;
      String factureNumber = factureNumberController.text;
        
        
      NewCommission commission = NewCommission(
        date: DateTime.now(),
        project: NewProjectInfo(
          clientName: clientName,
          clientNumber: clientNumber,
          service: _selectedItem!,
          name: projectName,
          pay: services.firstWhere((element) => (element.name == _selectedItem!)).commercialPay
        ),
        employee: widget.employee.employeeInfo.email,
        numeroFacture: factureNumber,
        status: Status.notPayed
      );
      
      createNewCommission(commission).then((value) {
          Navigator.pop(context);
      });


      return ;  
    }

    return ;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xff444444),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Add NCommission'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              color: AppColors.backgroundColor,
              child: Padding(
                padding: const EdgeInsets.only(top: 40, bottom: 40, right: 20, left: 20),
                child: SizedBox(
                  width: 400,
                  child:  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextField(
                        controller: clientNameController,
                        decoration: InputDecoration(
                          labelText: 'Nom du Client',
                          border: const OutlineInputBorder(),
                          errorText: getGenericError(clientNameController),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: clientNumberController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          labelText: 'Numéro du Client',
                          border: const OutlineInputBorder(),
                          errorText: getGenericError(clientNumberController),
                        ),
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: _selectedItem,
                        decoration: InputDecoration(
                          labelText: 'Service', // Label text for the dropdown button
                          border: OutlineInputBorder(), // Border style for the dropdown button
                          errorText: getServicesError()
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedItem = newValue!; // Update the selected item
                            montant = services.firstWhere((element) => element.name == _selectedItem).commercialPay;
                          });
                        },
                        items: serviceNames.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: projectNameController,
                        decoration: InputDecoration(
                          labelText: 'Nom du projet',
                          border: const OutlineInputBorder(),
                          errorText: getGenericError(projectNameController),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: factureNumberController,
                        decoration: InputDecoration(
                          labelText: 'Numéro de facture',
                          border: const OutlineInputBorder(),
                          errorText: getGenericError(factureNumberController),
                        ),
                      ),
                      const SizedBox(height: 25),
                      Center(
                        child: SizedBox(
                          child: Text(
                            "Montant: " + montant.toString() + " DA",
                            style: TextStyle(
                              fontSize: 26
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () => {
                            processInput()
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(AppColors.primaryColor)  
                          ),
                          child: const Text('Save'), // Button text
                        )
                      ) 
                    ],
                  ),
                ),
              )
            ) 
          ), 
        )
      )
       // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
