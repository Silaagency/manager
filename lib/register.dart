import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/data.dart';
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


  void processInput()
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

    if (validFields == fieldCount){
      // form is valid

      String name = nameController.text;
      String email = emailController.text;
      String phone = phoneController.text;
      String password = passwordController.text;
      
      NewEmployeeInfo emp = NewEmployeeInfo(name: name, email: email, phone: phone, password: password, service: _selectedItem!);

      checkEmail(email).then((value) => {
        if (value == true) {
          setState(() {
            emailUsed = true;
          })
        }
        else if (value == false){
          Navigator.pop(context),
          createNewEmployee(emp), 
          //TO DO: make sure employee gets created before quiting
        }
      });
    }

    return;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Color(0xff444444),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Register'),
      ),
      body: Center(
        
        child: Container(
          color: AppColors.backgroundColor, 
          child: Padding(
            padding: EdgeInsets.all(16.0),
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
                    labelText: 'Name',
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
                      labelText: 'Phone',
                      border: const OutlineInputBorder(),
                      errorText: getGenericError(phoneController),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    errorText: getGenericError(passwordController),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Container( 
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        processInput();
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(AppColors.primaryColor)  
                      ),
                      child: const Text('Register'), // Button text
                    ),
                  )
                ],
              ),
            ),
          )
        ) 
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
