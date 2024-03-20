import 'data.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

String sessionId = "";
String email = "";

String _baseUrl = "https://manager-backend-self.vercel.app";

Future<void> saveSessionIdAndEmail(String _sessionId, String _email) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('sessionId', _sessionId);
  await prefs.setString('email', _email);
  sessionId = _sessionId;
  email = _sessionId;
}

Future<String?> getSessionId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('sessionId');
}

Future<String?> getEmail() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('email');
}


Future<List<Service>> fetchServices() async {
  final response = await http.get(Uri.parse('$_baseUrl/services'));

  if (response.statusCode == 200) {
    final services = (jsonDecode(response.body) as List)
        .map((service) => Service.fromJson(service))
        .toList();
    return services;
  } else {
    throw Exception('Failed to fetch services');
  }
}

// Function to fetch a specific service by name
Future<Service> fetchServiceByName(String name) async {
  final response = await http.get(Uri.parse('$_baseUrl/services/$name'));

  if (response.statusCode == 200) {
    final service = Service.fromJson(jsonDecode(response.body));
    return service;
  } else {
    throw Exception('Failed to fetch service');
  }
}

Future<Service> deleteServiceByName(String name) async {
  final response = await http.delete(Uri.parse('$_baseUrl/services/$name'));

  if (response.statusCode == 200) {
    final service = Service.fromJson(jsonDecode(response.body));
    return service;
  } else {
    throw Exception('Failed to fetch service');
  }
}

Future<Service> createService(Service service) async {
  final response = await http.post(
    Uri.parse('$_baseUrl/services'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'name': service.name,
      'commercialPay': service.commercialPay,
      'commissions': service.commissions.map((commission) => commission.toJson()).toList(),
    }),
  );

  if (response.statusCode == 201) {
    final createdService = Service.fromJson(jsonDecode(response.body));
    return createdService;
  } else {
    throw Exception('Failed to create service');
  }
}

Future<Service> updateService(String name, Service updatedService) async {
  final response = await http.put(
    Uri.parse('$_baseUrl/services/$name'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'newName' : updatedService.name,
      'commercialPay': updatedService.commercialPay,
      'commissions': updatedService.commissions.map((commission) => commission.toJson()).toList(),
    }),
  );

  if (response.statusCode == 200) {
    final updatedServiceData = Service.fromJson(jsonDecode(response.body));
    return updatedServiceData;
  } else {
    throw Exception('Failed to update service');
  }
}

Future<(Employee, String)> login(String email, String password) async {
  final url = Uri.parse('$_baseUrl/login');
  final headers = {'Content-Type': 'application/json'};
  final body = json.encode({'email': email, 'password': password});

  try {
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final sessionId = jsonResponse['sessionId'];
      final identity = jsonResponse['identity'];
      await saveSessionIdAndEmail(sessionId, email);
      final emp = Employee.fromJson(jsonResponse["employee"]);
      return (emp, identity as String);
    } else if (response.statusCode == 401) {
      throw Exception('Invalid email or password');
    } else {
      throw Exception('Failed to login');
    }
  } on Exception catch (e) {
    throw Exception(e.toString().substring(11));
  }
}


Future<(Employee?, String)> loginWithId() async {
  final url = Uri.parse('$_baseUrl/login-session');
  final headers = {'Content-Type': 'application/json'};
  final body = json.encode({'email': await getEmail(), 'sessionId': await getSessionId()});

  try {
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final identity = jsonResponse['identity'];
      final emp = Employee.fromJson(jsonResponse["employee"]);
      return (emp, identity as String);
    } else if (response.statusCode == 401) {
      return (null, "failed");
    } else {
      return (null, "failed");
    }
  } catch (e) {
    throw Exception('Error: $e');
  }
}

Future<bool?> checkEmail(String _email) async {
  final url = '$_baseUrl/email-used';
  final headers = {'Content-Type': 'application/json'};

  try {
    final uri = Uri.parse(url).replace(queryParameters: {"email": _email});
    final response = await http.get(uri);

    if (response.statusCode == 200){
      final bool res = json.decode(response.body)["used"];
      return res;
    } else {
      print("Failed to check email");
    }
    
  } catch(e) {
    print('Error: $e');
  }
}

Future<bool?> checkName(String _email, String _name) async {
  final url = '$_baseUrl/project-name-used';
  final headers = {'Content-Type': 'application/json'};

  try {
    final uri = Uri.parse(url).replace(queryParameters: {"email": _email, "name" : _name});
    final response = await http.get(uri);

    if (response.statusCode == 200){
      final bool res = json.decode(response.body)["used"];
      return res;
    } else {
      print("Failed to check project name");
    }
    
  } catch(e) {
    print('Error: $e');
  }
}

Future<void> createNewEmployee(NewEmployeeInfo newEmployeeInfo) async {
  final url = Uri.parse('$_baseUrl/new-employees');
  final headers = {'Content-Type': 'application/json'};

  try {
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(newEmployeeInfo.toJson()),
    );

    if (response.statusCode == 201) {
      print('New employee created successfully');
    } else {
      print('Failed to create new employee');
      print(response.body);
    }
  } catch (e) {
    print('Error: $e');
  }
}

Future<void> confirmEmployee(Employee employee) async {
  final url = Uri.parse('$_baseUrl/employees');
  final headers = {'Content-Type': 'application/json'};

  try {
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(employee.toJson()),
    );

    if (response.statusCode == 201) {
      print('New employee created successfully');
    } else {
      print('Failed to create new employee');
      print(response.body);
    }
  } catch (e) {
    print('Error: $e');
  }
}


Future<List<EmployeeInfo>> fetchNewEmployees() async {
  final response = await http.get(Uri.parse('$_baseUrl/new-employees'));

  if (response.statusCode == 200) {
    final jsonBody = json.decode(response.body);
    final employees = (jsonBody as List).map((json) => EmployeeInfo.fromJson(json)).toList();
    return employees;
  } else {
    throw Exception('Failed to load employees');
  }
}

Future<List<Employee>> fetchEmployees({
  Map<String, String>? filters,
}) async {
  final uri = Uri.parse('$_baseUrl/employees').replace(
    queryParameters: filters,
  );
  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final List<dynamic> responseData = jsonDecode(response.body);
    return responseData.map((e) => Employee.fromJson(e)).toList();
  } else {
    throw Exception('Failed to load new employees: ${response.statusCode}');
  }
}

Future<Employee> fetchEmployeeByEmail(String email) async {
  final response = await http.get(Uri.parse('$_baseUrl/employees/$email'));

  if (response.statusCode == 200) {
    final employee = Employee.fromJson(jsonDecode(response.body));
    return employee;
  } else {
    throw Exception('Failed to fetch employee');
  }
}

Future<Employee> updateEmployee(String email, Employee updatedEmployee) async {
  final response = await http.put(
    Uri.parse('$_baseUrl/employees/$email'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'employeeInfo' : updatedEmployee.employeeInfo,
      'paymentInfo': updatedEmployee.paymentInfo,
    }),
  );

  if (response.statusCode == 200) {
    final updatedEmployeeData = Employee.fromJson(jsonDecode(response.body));
    return updatedEmployeeData;
  } else {
    throw Exception('Failed to update employee');
  }
}


Future<Commission> createCommission(Commission commission) async {
  final response = await http.post(
    Uri.parse('$_baseUrl/commissions'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(commission.toJson()),
  );
  if (response.statusCode == 201) {
    return Commission.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to create commission');
  }
}

Future<NewCommission> createNewCommission(NewCommission newCommission) async {
  final response = await http.post(
    Uri.parse('$_baseUrl/new-commissions'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(newCommission.toJson()),
  );
  if (response.statusCode == 201) {
    return NewCommission.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to create new commission');
  }
}

Future<List<Commission>> getCommissions({Map<String, dynamic>? filters}) async {
  final uri = Uri.parse('$_baseUrl/commissions').replace(queryParameters: filters);

  final response = await http.get(uri);
  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Commission.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load commissions');
  }
}

Future<List<NewCommission>> getNewCommissions({Map<String, dynamic>? filters}) async {
  final uri = Uri.parse('$_baseUrl/new-commissions').replace(queryParameters: filters);

  final response = await http.get(uri);
  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => NewCommission.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load new commissions');
  }
}

Future<NewCommission> updateNewCommission(NewCommission newCommission, {Map<String, String>? filters}) async {
  final queryParameters = <String, String>{
    ...?filters ?? {},
  };

  final uri = Uri.parse('$_baseUrl/new-commissions').replace(queryParameters: queryParameters);

  final response = await http.put(
    uri,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(newCommission.toJson()),
  );

  if (response.statusCode == 200) {
    return NewCommission.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to update new commission: ${response.statusCode}');
  }
}

Future<Commission> updateCommission(Commission commission, {Map<String, String>? filters}) async {
  final queryParameters = <String, String>{
    ...?filters ?? {},
  };

  queryParameters["employee"] = commission.employee;
  queryParameters["date"] = commission.date.toIso8601String();

  
  final uri = Uri.parse('$_baseUrl/commissions').replace(queryParameters: queryParameters);

  final response = await http.put(
    uri,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(commission.toJson()),
  );

  if (response.statusCode == 200) {
    return Commission.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to update commission: ${response.statusCode}');
  }
}

Future<List<Payment>> getPayments({Map<String, String>? filters}) async {
  final queryParameters = <String, String>{
    ...?filters ?? {},
  };

  final uri = Uri.parse('$_baseUrl/payments').replace(queryParameters: queryParameters);

  final response = await http.get(uri);
  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Payment.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load payments');
  }
}

Future<Payment> createPayment(Payment payment) async {
  final response = await http.post(
    Uri.parse('$_baseUrl/payments'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(payment.toJson()),
  );
  if (response.statusCode == 201) {
    return Payment.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to create payment');
  }
}

Future<List<FinalPayment>> getFinalPayments({Map<String, String>? filters}) async {
  final queryParameters = <String, String>{
    ...?filters ?? {},
  };

  final uri = Uri.parse('$_baseUrl/final-payments').replace(queryParameters: queryParameters);

  final response = await http.get(uri);
  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => FinalPayment.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load final payments');
  }
}

Future<FinalPayment> createFinalPayment(FinalPayment finalPayment) async {
  final response = await http.post(
    Uri.parse('$_baseUrl/final-payments'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(finalPayment.toJson()),
  );
  if (response.statusCode == 201) {
    return FinalPayment.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to create final payment');
  }
}

Future<FinalPayment?> getLatestFinalPayment({Map<String, String>? filters}) async {
    final queryParameters = <String, String>{
      ...?filters ?? {},
    };

    final uri = Uri.parse('$_baseUrl/last-final-payment').replace(queryParameters: queryParameters);

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        return FinalPayment.fromJson(data[0]);
      }
    } else {
      throw Exception('Failed to load latest final payment');
    }
    return null;
  }