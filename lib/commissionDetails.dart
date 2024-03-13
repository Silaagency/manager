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
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class CommissionDetailsPage extends StatefulWidget {
  const CommissionDetailsPage({super.key, required this.commission});

  final Commission commission;

  @override
  State<CommissionDetailsPage> createState() => _CommissionDetailsPageState();

}


class _CommissionDetailsPageState extends State<CommissionDetailsPage> with RouteAware  {

  Employee? employee;
  Status? _selectedItem;

  TextEditingController CommentController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _selectedItem = widget.commission.status;
    CommentController.text = widget.commission.employerComment;
  }

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
    // if something changed then it must be stored
    Commission com = widget.commission;
    if (com.employerComment != CommentController.text || com.status != _selectedItem) {
      com.employerComment = CommentController.text;
      com.status = _selectedItem!;
      updateCommission(com, filters: {"employee" : widget.commission.employee, "project.name" : widget.commission.project.name}).then((value) => Navigator.pop(context));
    }
    return ;
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

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.zeroColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Details"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
          width: 450,
            child: Card(
              elevation: 5,
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
                            padding: EdgeInsets.only(left: 40, right: 40, top: 30, bottom: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  child: Text(
                                    "Date",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ) 
                                ),
                                SizedBox(
                                  child: Text(
                                    DateFormat('yyyy-MM-dd HH:mm:ss').format(widget.commission.date),
                                    style: TextStyle(fontSize: 20),
                                  ) 
                                ),
                                SizedBox(height: 15,),
                                const SizedBox(
                                  child: Text(
                                    "Nom du Client",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ) 
                                ),
                                SizedBox(
                                  child: Text(
                                    widget.commission.project.clientName,
                                    style: TextStyle(fontSize: 20),
                                  ) 
                                ),
                                SizedBox(height: 15,),
                                const SizedBox(
                                  child: Text(
                                    "Numéro de téléphone",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ) 
                                ),
                                SizedBox(
                                  child: Text(
                                    widget.commission.project.clientNumber,
                                    style: TextStyle(fontSize: 20),
                                  ) 
                                ),
                                SizedBox(height: 15,),
                                const SizedBox(
                                  child: Text(
                                    "Type de Projet",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ) 
                                ),
                                SizedBox(
                                  child: Text(
                                    widget.commission.project.type,
                                    style: TextStyle(fontSize: 20),
                                  ) 
                                ),
                                SizedBox(height: 15,),
                                const SizedBox(
                                  child: Text(
                                    "Quantité",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ) 
                                ),
                                SizedBox(
                                  child: Text(
                                    widget.commission.project.quantity.toString(),
                                    style: TextStyle(fontSize: 20),
                                  ) 
                                ),
                                SizedBox(height: 15,),
                                const SizedBox(
                                  child: Text(
                                    "Nom du projet",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ) 
                                ),
                                SizedBox(
                                  child: Text(
                                    widget.commission.project.name,
                                    style: TextStyle(fontSize: 20),
                                  ) 
                                ),
                                SizedBox(height: 15,),
                                const SizedBox(
                                  child: Text(
                                    "Montant",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ) 
                                ),
                                SizedBox(
                                  child: Text(
                                    widget.commission.project.pay.toString() + " DA",
                                    style: TextStyle(fontSize: 20),
                                  ) 
                                ),
                                SizedBox(height: 15,),
                                Row(
                                  children: [
                                    const SizedBox(
                                      child: Text(
                                        "Commentaire de l'employé",
                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                      ) 
                                    ),
                                    SizedBox(width: 20,),
                                    SizedBox(
                                      height: 40,
                                      width: 40,
                                      child: IconButton(
                                        onPressed: () => {
                                          
                                          Clipboard.setData(ClipboardData(text: widget.commission.employeeComment)),
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Copied to clipboard'))),
                                        },
                                        style: ButtonStyle(
                                          backgroundColor: MaterialStateProperty.all<Color>(AppColors.primaryColor)
                                        ),
                                        icon: Icon(Icons.copy),
                                      )
                                    ) 
                                  ],
                                ),
                                SizedBox(
                                  child: Text(
                                    widget.commission.employeeComment,
                                    textAlign: TextAlign.justify,
                                    style: TextStyle(fontSize: 20),
                                  ) 
                                ),
                                SizedBox(height: 15,),
                                const SizedBox(
                                  child: Text(
                                    "Commentaire",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ) 
                                ),
                                SizedBox(height: 15,),
                                TextField(
                                  controller: CommentController,
                                  maxLines: 2,
                                  decoration: InputDecoration(
                                    labelText: 'Commentaire',
                                    border: const OutlineInputBorder(),
                                    hintMaxLines: 2
                                  ),
                                ),
                                SizedBox(height: 30,),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      child: Text(
                                        "Status",
                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                      ) 
                                    ),
                                    SizedBox(width: 40,),
                                    (_selectedItem !=Status.payed ? Expanded(
                                      child: DropdownButtonFormField<Status>(
                                        value: _selectedItem,
                                        decoration: InputDecoration(
                                          labelText: 'Status', // Label text for the dropdown button
                                          border: OutlineInputBorder(), // Border style for the dropdown button
                                        ),
                                        onChanged: (Status? newValue) {
                                          setState(() {
                                            _selectedItem = newValue!; // Update the selected item
                                          });
                                        },
                                        items: [
                                          DropdownMenuItem<Status>(value: Status.notPayed, child: Text("Non Payé")),
                                          DropdownMenuItem<Status>(value: Status.canceled, child: Text("Annulé"))
                                        ],
                                      ),
                                    ):Text("payed", style: TextStyle(fontSize: 20))),
                                  ],
                                ),
                                SizedBox(height: 50,),
                                Center(
                                  child: SizedBox(
                                    height: 40,
                                    width: 300,
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
                                )
                              ],
                            ), 
                          ),
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