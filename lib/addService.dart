import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:Manager/data.dart';
import 'package:Manager/database.dart';
import 'constants.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';


class AddServicePage extends StatefulWidget {
  const AddServicePage({super.key, this.service});

  final Service? service;

  @override
  State<AddServicePage> createState() => _AddServicePageeState();
}

class _AddServicePageeState extends State<AddServicePage> {
  List<Widget> rows = [];
  
  TextEditingController nameController = TextEditingController();
  TextEditingController commercialPayController = TextEditingController();
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

  @override
  void initState() {
    super.initState();

    if (widget.service != null)
    {
      nameController.text = widget.service!.name;
      commercialPayController.text = widget.service!.commercialPay.toString();

      for (CommissionType com in widget.service!.commissions)
      {
        textControllers.add(
          [
            TextEditingController(text: com.name),
            TextEditingController(text: com.pay.toString())
          ]
        );
      }
    }
  }

  void processInput()
  {
    int fieldCount = 2 + (2 * textControllers.length);
    int validFields = 0;
    setState(() {
      savePressed = true;
    });

    List<CommissionType> commissions = List.empty(growable: true);

    if (!nameController.text.isEmpty){
      validFields++;
    }

    if (!commercialPayController.text.isEmpty){
      validFields++;
    }

    for (int i = 0; i < textControllers.length; i++)
    {
      if (textControllers[i][0].text.isEmpty){
        break;
      }
      else if (textControllers[i][1].text.isEmpty){
        break;
      }
      else {
        validFields+=2;
      }


      commissions.add(CommissionType(
        name: textControllers[i][0].text,
        pay: int.parse(textControllers[i][1].text)
      ));

    }

    if (validFields == fieldCount){
      
      // form is valid
      String name = nameController.text;
      int commercialPay = int.parse(commercialPayController.text);
      

      Service service = Service(name: name, commercialPay: commercialPay, commissions: commissions);
      // add service
      try {
        if (widget.service == null)
        {
          createService(service).then((value) => {Navigator.pop(context)});
          showToast("service created", context:context);
          //Data.services.add();
        }
        // modify service
        else
        {
          updateService(widget.service!.name, service).then((value) => {
            Navigator.pop(context, service.name)
          });
          showToast("service updated", context:context);
        }

      } catch(e) {
        showToast(e.toString(), context:context);
      }

      return;  
    }

    return;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.zeroColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Ajouter un service'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Center(
            child: Card(
              color: AppColors.backgroundColor,
              child: Padding(
                padding: const EdgeInsets.only(top: 40, bottom: 40, right: 30, left: 30),
                child: SizedBox(
                  width: 400,
                  child:  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Nom',
                          border: const OutlineInputBorder(),
                          errorText: getGenericError(nameController),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: commercialPayController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          labelText: 'Payment Commercial',
                          suffix: const Text("DA"),
                          border: const OutlineInputBorder(),
                          errorText: getGenericError(commercialPayController),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: textControllers.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 50,
                                    child: TextField(
                                      controller: textControllers[index][0],
                                      decoration: InputDecoration(
                                      labelText: 'Nom',
                                      border: const OutlineInputBorder(),
                                      errorText: getGenericError(textControllers[index][0]),
                                      ),
                                    )
                                  ) 
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: SizedBox(
                                    height: 50,
                                    child: TextField(
                                      controller: textControllers[index][1],
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                      decoration: InputDecoration(
                                        labelText: 'Montant',
                                        suffix: const Text("DA"),
                                        border: const OutlineInputBorder(),
                                        errorText: getGenericError(textControllers[index][1]),
                                      ),
                                    )
                                  ) 
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      SizedBox( 
                        height: 40,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: () => {
                                    setState(() {
                                      TextEditingController controller1 = TextEditingController();
                                      TextEditingController controller2 = TextEditingController();
                                      
                                      textControllers.add([controller1, controller2]);

                                    })
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all<Color>(AppColors.primaryColor)  
                                  ),
                                  child: const Text('Ajouter'), // Button text
                                )
                              ) 
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: SizedBox(
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: () => {
                                    (textControllers.isEmpty) ? null:setState(() => textControllers.removeLast())
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all<Color>(AppColors.primaryColor)  
                                  ),
                                  child: const Text('Remove'), // Button text
                                )
                              ) 
                            ),
                          ],
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
                          child: const Text('Enregistrer'), // Button text
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
