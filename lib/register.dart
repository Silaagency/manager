import 'package:async_button/async_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:Manager/data.dart';
import 'constants.dart';
import 'database.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  bool savePressed = false;
  String? _selectedItem;
  List<String> services = List.empty(growable: true);

  @override
  void initState() {
    services.add("Commercial");

    fetchServices().then((value) {
      setState(() {
        services.addAll(value.map((e) => e.name));
      });
    });
  }

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  
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

  bool emailUsed = false;

  String? getEmailError(TextEditingController controller){
    if (!savePressed) return null;
    else
    {
      if (controller.text.isEmpty) return "This field Cannot be left Empty";
      else if (emailUsed) return "this email has been used already";
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
    const int fieldCount = 5;
    int validFields = 0;
    emailUsed = false;

    setState(() {
      savePressed = true;
    });

    if (nameController.text.isNotEmpty){
      validFields++;
    }

    if (emailController.text.isNotEmpty){
      validFields++;
    }

    if (phoneController.text.isNotEmpty){
      validFields++;
    }

    if (passwordController.text.isNotEmpty){
      validFields++;
    }

    if (_selectedItem != null)
    {
      validFields++;
    }

    if (validFields == fieldCount) {

      String name = nameController.text.trim();
      String email = emailController.text.trim();
      String phone = phoneController.text.trim();
      String password = passwordController.text;
      
      NewEmployeeInfo emp = NewEmployeeInfo(name: name, email: email, phone: phone, password: password, service: _selectedItem!);

      final status = await checkEmail(email);
      
      if (status == true) {
        setState(() {
          emailUsed = true;
        });
      } else if (status == false) {
        await createNewEmployee(emp);
        Navigator.pop(context);
        
      }
    }
  }

  AsyncBtnStatesController btnStateController = AsyncBtnStatesController();



  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: AppColors.zeroColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Inscrivez-vous'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Card(
                  elevation: 5,
                  color: AppColors.backgroundColor, 
                  child: Padding(
                    padding: EdgeInsets.all(26.0),
                    child: SizedBox(
                      width: 400,
                      child:  Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
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
                              });
                            },
                            items: services.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                            labelText: 'Nom',
                            border: OutlineInputBorder(),
                            errorText: getGenericError(nameController),
                            ),    
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              border: const OutlineInputBorder(),
                              errorText: getEmailError(emailController),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: phoneController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: InputDecoration(
                              labelText: 'Numéro de téléphone',
                              border: const OutlineInputBorder(),
                              errorText: getGenericError(phoneController),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                            labelText: 'mot de passe',
                            border: const OutlineInputBorder(),
                            errorText: getGenericError(passwordController),
                            ),
                          ),
                          const SizedBox(height: 25),
                          Container(
                            height: 40,
                            child: AsyncElevatedBtn.withDefaultStyles(
                              asyncBtnStatesController: btnStateController,
                              onPressed: () async {
                                try {
                                  btnStateController.update(AsyncBtnState.loading);
                                  await processInput();
                                  btnStateController.update(AsyncBtnState.idle);
                                } catch(e) {
                                  btnStateController.update(AsyncBtnState.failure);
                                }
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(AppColors.primaryColor)  
                              ),
                              child: Text("S'inscrire", style: defaultTextStyle), // Button text
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ) 
              ]
            )
          )
        )
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
