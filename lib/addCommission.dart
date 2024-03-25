import 'package:async_button/async_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:Manager/data.dart';
import 'package:Manager/database.dart';
import 'constants.dart';


class AddCommissionPage extends StatefulWidget {
  const AddCommissionPage({super.key, required this.employee});

  final Employee employee;

  @override
  State<AddCommissionPage> createState() => _AddCommissionPageState();
}

class _AddCommissionPageState extends State<AddCommissionPage> {

  String? _selectedItem;
  List<CommissionType> commissions = List.empty(growable: true);
  int montant = 0;

  int montantTotal()
  {
    if (quantityController.text == "")
      return 0;
    return montant * int.parse(quantityController.text) ;
  }

  @override
  void initState() {
    // TODO: implement initState
    fetchServiceByName(widget.employee.employeeInfo.service).then((value) {
      setState(() {
        commissions.addAll(value.commissions);
      });
    });
  }

  TextEditingController clientNameController = TextEditingController();
  TextEditingController clientNumberController = TextEditingController();
  TextEditingController projectNameController = TextEditingController();
  TextEditingController employeeCommentController = TextEditingController();
  TextEditingController quantityController = TextEditingController(text: "1");

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

  Future<void> processInput() async
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

    if (!quantityController.text.isEmpty){
      validFields++;
    }

    if (_selectedItem != null)
      validFields++;

    if (validFields == fieldCount){
      // form is valid

      String clientName = clientNameController.text;
      String clientNumber = clientNumberController.text;
      String projectName = projectNameController.text;
      String quantity = quantityController.text;
      String employeeComment = employeeCommentController.text;
        
      Commission commission = Commission(
        date: DateTime.now(),
        project: ProjectInfo(
          clientName: clientName,
          clientNumber: clientNumber,
          service: widget.employee.employeeInfo.service,
          type: _selectedItem!,
          name: projectName,
          quantity: int.parse(quantity),
          pay: montantTotal()
        ),
        employee: widget.employee.employeeInfo.email,
        employeeComment: employeeComment,
        status: Status.notPayed
      );
      
      await createCommission(commission);
      Navigator.pop(context);

      return ;
    }

    return ;
  }

  AsyncBtnStatesController btnStateController = AsyncBtnStatesController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.zeroColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Ajouter une Commission'),
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
                          labelText: 'Commission', // Label text for the dropdown button
                          border: OutlineInputBorder(), // Border style for the dropdown button
                          errorText: getServicesError()
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedItem = newValue!; // Update the selected item
                            montant = commissions.firstWhere((element) => element.name == _selectedItem).pay;

                          });
                        },
                        items: commissions.map<DropdownMenuItem<String>>((CommissionType value) {
                          return DropdownMenuItem<String>(
                            value: value.name,
                            child: Text(value.name),
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
                        controller: quantityController,
                        
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: (value){
                          setState(() {
                            
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Quantité',
                          border: const OutlineInputBorder(),
                          errorText: getGenericError(quantityController),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: employeeCommentController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Commentaire',
                          border: const OutlineInputBorder(),
                          hintMaxLines: 2
                        ),
                      ),
                      const SizedBox(height: 25),
                      Center(
                        child: SizedBox(
                          child: Text(
                            "Montant: " + montantTotal().toString() + " DA",
                            style: TextStyle(
                              fontSize: 26
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        height: 40,
                        child: AsyncElevatedBtn.withDefaultStyles(
                          asyncBtnStatesController: btnStateController,
                          onPressed: () async {
                            try {
                              btnStateController.update(AsyncBtnState.loading);
                              await processInput();
                            } catch (e) {
                              btnStateController.update(AsyncBtnState.idle);
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(AppColors.primaryColor)  
                          ),
                          child: Text('Confirmer', style: defaultTextStyle), // Button text
                        ),
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
