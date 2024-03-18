
import 'package:flutter/material.dart';
import 'dart:convert';

enum Status { notPayed, payed, canceled }

class CommissionType {
  final String name;
  final int pay;

  CommissionType({required this.name, required this.pay});

  Map<String, dynamic> toJson() => {
        'name': name,
        'pay': pay,
      };

  factory CommissionType.fromJson(Map<String, dynamic> json) => CommissionType(
        name: json['name'],
        pay: json['pay'],
      );
}

class Service {
  String name;
  final int commercialPay;
  final List<CommissionType> commissions;

  Service({
    required this.name,
    required this.commercialPay,
    required this.commissions,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'commercialPay': commercialPay,
        'commissions': commissions.map((commission) => commission.toJson()).toList(),
      };

  factory Service.fromJson(Map<String, dynamic> json) => Service(
        name: json['name'],
        commercialPay: json['commercialPay'],
        commissions: List<CommissionType>.from(
          json['commissions'].map((commission) => CommissionType.fromJson(commission)),
        ),
      );
}

class NewEmployeeInfo {
  final String name;
  final String service;
  final String email;
  final String password;
  final String phone;

  NewEmployeeInfo({
    required this.name,
    required this.service,
    required this.email,
    required this.password,
    required this.phone,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'service': service,
        'email': email,
        'password': password,
        'phone': phone,
      };

  factory NewEmployeeInfo.fromJson(Map<String, dynamic> json) => NewEmployeeInfo(
        name: json['name'],
        service: json['service'],
        email: json['email'],
        password: json['password'],
        phone: json['phone'],
      );
}

class EmployeeInfo {
  final String name;
  final String service;
  final String email;
  final String phone;

  EmployeeInfo({
    required this.name,
    required this.service,
    required this.email,
    required this.phone,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'service': service,
        'email': email,
        'phone': phone,
      };

  factory EmployeeInfo.fromJson(Map<String, dynamic> json) => EmployeeInfo(
        name: json['name'],
        service: json['service'],
        email: json['email'],
        phone: json['phone'],
      );
}

class PaymentInfo {
  final bool hasSalary;
  final bool paidCommissions;
  final bool penalizedAbsence;
  final int salary;
  int absence;

  PaymentInfo({
    required this.hasSalary,
    required this.paidCommissions,
    required this.penalizedAbsence,
    required this.salary,
    this.absence = 0,
  });

  Map<String, dynamic> toJson() => {
        'hasSalary': hasSalary,
        'paidCommissions': paidCommissions,
        'penalizedAbsence': penalizedAbsence,
        'salary': salary,
        'absence': absence,
      };

  factory PaymentInfo.fromJson(Map<String, dynamic> json) => PaymentInfo(
        hasSalary: json['hasSalary'],
        paidCommissions: json['paidCommissions'],
        penalizedAbsence: json['penalizedAbsence'],
        salary: json['salary'],
        absence: json['absence'] ?? 0,
      );
}

class Employee {
  final EmployeeInfo employeeInfo;
  final PaymentInfo paymentInfo;

  Employee({
    required this.employeeInfo,
    required this.paymentInfo,
  });

  Map<String, dynamic> toJson() => {
        'employeeInfo': employeeInfo.toJson(),
        'paymentInfo': paymentInfo.toJson(),
      };

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
        employeeInfo: EmployeeInfo.fromJson(json['employeeInfo']),
        paymentInfo: PaymentInfo.fromJson(json['paymentInfo']),
      );
}

class ProjectInfo {
  String service;
  String type;
  int quantity;
  int pay;
  String clientName;
  String clientNumber;
  String name;

  ProjectInfo({
    this.service = '',
    this.type = '',
    this.quantity = 0,
    this.pay = 0,
    this.clientName = '',
    this.clientNumber = '',
    this.name = '',
  });

  Map<String, dynamic> toJson() => {
        'service': service,
        'type': type,
        'quantity': quantity,
        'pay': pay,
        'clientName': clientName,
        'clientNumber': clientNumber,
        'name': name,
      };

  factory ProjectInfo.fromJson(Map<String, dynamic> json) => ProjectInfo(
        service: json['service'],
        type: json['type'],
        quantity: json['quantity'],
        pay: json['pay'],
        clientName: json['clientName'],
        clientNumber: json['clientNumber'],
        name: json['name'],
      );
}

class NewProjectInfo {
  String service;
  int pay;
  String clientName;
  String clientNumber;
  String name;

  NewProjectInfo({
    this.service = '',
    this.pay = 0,
    this.clientName = '',
    this.clientNumber = '',
    this.name = '',
  });

  Map<String, dynamic> toJson() => {
        'service': service,
        'pay': pay,
        'clientName': clientName,
        'clientNumber': clientNumber,
        'name': name,
      };

  factory NewProjectInfo.fromJson(Map<String, dynamic> json) => NewProjectInfo(
        service: json['service'],
        pay: json['pay'],
        clientName: json['clientName'],
        clientNumber: json['clientNumber'],
        name: json['name'],
      );
}

class NewCommission {
  DateTime date;
  NewProjectInfo project;
  String employee;
  String comment;
  String numeroFacture;
  Status status;

  NewCommission({
    DateTime? date,
    NewProjectInfo? project,
    this.employee = '',
    this.numeroFacture = '',
    this.comment = '',
    this.status = Status.notPayed,
  })  : this.date = date ?? DateTime.now(),
        this.project = project ?? NewProjectInfo();

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'project': project.toJson(),
        'employee': employee,
        'numeroFacture': numeroFacture,
        'comment': comment,
        'status': status.name,
      };

  factory NewCommission.fromJson(Map<String, dynamic> json) => NewCommission(
        date: DateTime.parse(json['date']),
        project: NewProjectInfo.fromJson(json['project']),
        employee: json['employee'],
        numeroFacture: json['numeroFacture'],
        comment: json['comment'],
        status: Status.values.byName(json['status']),
      );
}

class Commission {
  DateTime date;
  ProjectInfo project;
  String employee;
  Status status;
  String employeeComment;
  String employerComment;

  Commission({
    DateTime? date,
    ProjectInfo? project,
    this.employee = '',
    this.status = Status.notPayed,
    this.employeeComment = '',
    this.employerComment = '',
  })  : this.date = date ?? DateTime.now(),
        this.project = project ?? ProjectInfo();

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'project': project.toJson(),
        'employee': employee,
        'status': status.name,
        'employeeComment': employeeComment,
        'employerComment': employerComment,
      };

  factory Commission.fromJson(Map<String, dynamic> json) => Commission(
        date: DateTime.parse(json['date']),
        project: ProjectInfo.fromJson(json['project']),
        employee: json['employee'],
        status: Status.values.byName(json['status']),
        employeeComment: json['employeeComment'],
        employerComment: json['employerComment'],
      );
}



class PaymentDetails {
  PaymentDetails({
    required this.salary,
    required this.commissions,
    required this.penalty,
    required this.prepaid,
    required this.payed,
  });

  final int salary;
  final int commissions;
  final int penalty;
  final int prepaid;
  final int payed;

  factory PaymentDetails.fromJson(Map<String, dynamic> json) {
    return PaymentDetails(
      salary: json['salary'],
      commissions: json['commissions'],
      penalty: json['penalty'],
      prepaid: json['prepaid'],
      payed: json['payed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'salary': salary,
      'commissions': commissions,
      'penalty': penalty,
      'prepaid': prepaid,
      'payed': payed
    };
  }
}

class Payment {
  Payment({
    required this.employee,
    required this.comment,
    required this.date,
    required this.amount,
  });

  final String employee;
  final String comment;
  final DateTime date;
  final int amount;

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      employee: json['employee'],
      comment: json['comment'],
      date: DateTime.parse(json['date']),
      amount: json['amount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employee': employee,
      'comment': comment,
      'date': date.toIso8601String(),
      'amount': amount,
    };
  }
}

class FinalPayment {
  FinalPayment({
    required this.employee,
    required this.date,
    required this.amount,
    required this.details,
  });

  final String employee;
  final DateTime date;
  final int amount;
  final PaymentDetails details;

  factory FinalPayment.fromJson(Map<String, dynamic> json) {
    return FinalPayment(
      employee: json['employee'],
      date: DateTime.parse(json['date']),
      amount: json['amount'],
      details: PaymentDetails.fromJson(json['details']), 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employee': employee,
      'date': date.toIso8601String(),
      'amount': amount,
      'details': details.toJson()
    };
  }
}

/*
class Datat{
  static final List<Service> services = [
    Service(
      name: "development",
      commercialPay: 4000,
      commissions: <CommissionType>[CommissionType(name: "web", pay:20000), CommissionType(name: "star", pay:200000)]
    )
  ];
  static final List<NewCommission> newCommissions = List.empty(growable: true);
  static final List<Commission> commissions = List.empty(growable: true);
  static final List<EmployeeInfo> newEmployees = List.empty(growable: true);
  static final List<Employee> employees = [/*
    Employee(
      employeeInfo: EmployeeInfo(name: "khalfoune othmane", email: "kothmane@outlook.com", phone: "321313123", service: "development"),
      paymentInfo: PaymentInfo(hasSalary: true, paidCommissions: true, penalizedAbsence: false, salary: 40000)),
    Employee(
      employeeInfo: EmployeeInfo(name: "hamadi com", email: "c", phone: "1123123", service: "Commercial"),
      paymentInfo: PaymentInfo(hasSalary: true, paidCommissions: true, penalizedAbsence: true, salary: 20000))
  */];
}
*/

String StatusMessage(Status s)
{
  switch (s)
  {
    case Status.canceled:
      return "Annulé";
    case Status.notPayed:
      return "Non Payé";
    case Status.payed:
      return "Payé";
  }
}


enum Operation {
  Add,
  Edit
}

class Filter {
  Filter({bool this.payed = false, bool this.notPayed = true, bool this.canceled = false});

  bool payed;
  bool notPayed;
  bool canceled;

  void apply(Map<String, dynamic> filters)
  {
    List<String> list = [];
    if (payed)
      list.add("payed");
    if (notPayed)
      list.add("notPayed");
    if (canceled)
      list.add("canceled");

    filters["status"] = [...list];
  }
}

// global RouteObserver
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

abstract class FilteredList {
  Filter? getFilter();
  void setFilter(Filter filter);
}