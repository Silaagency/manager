import 'package:flutter/material.dart';
import 'package:Manager/addEmployee.dart';
import 'package:Manager/adminEmployeeDetails.dart';
import 'package:Manager/commissionDetails.dart';
import 'package:Manager/data.dart';
import 'package:Manager/database.dart';
import 'package:Manager/employeeMain.dart';
import 'package:Manager/newCommissionDetails.dart';
import 'constants.dart';
import 'package:intl/intl.dart';


class EmployeeListPage extends StatefulWidget {
  EmployeeListPage({super.key, required  this.isNew, this.filter});

  final bool isNew;
  final String? filter;

  _EmployeeListPageState? state = null;

  @override
  State<EmployeeListPage> createState() {
    state = _EmployeeListPageState();
    return state!;
  } 

  
  void updateData(){
    state!.rebuild();
  }
}


class _EmployeeListPageState extends State<EmployeeListPage> {
  
  List<EmployeeInfo> employees = List.empty();
  int length = 0;

  @override
  void initState() {
    updateData();
  }

  // this may cause a problem if one of the lists is empty, not sure, depends on List methods returned value when list is empty
  void updateData(){
    if (widget.isNew)
    {
      fetchNewEmployees().then((value) => setState(
        () {
          employees = value;
        }
      ));

    } else if (widget.filter == null) {
      fetchEmployees().then((value) =>  setState(() {
        employees = value.map((e) => e.employeeInfo).toList();
      }));  
      //employees = Data.employees.map((e) => e.employeeInfo).toList();

    } else {
      //employees = Data.employees.where((element) => (element.employeeInfo.service == widget.filter)).toList().map((e) => e.employeeInfo).toList();
      fetchEmployees(filters: { "employeeInfo.service" : widget.filter!}).then((value) =>  setState(() {
        employees = value.map((e) => e.employeeInfo).toList();
      }));
    }
      
  }


  void rebuild() {
    setState(() {
      updateData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 450,
      color: AppColors.backgroundColor,
      child:SingleChildScrollView(
        child: Center(
          child: Container(
            color: AppColors.backgroundColor,
            child: Padding(
              padding: const EdgeInsets.only( right: 20, left: 20),
              child: SizedBox(
                width: 450,
                child:  Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: employees.length,
                      itemBuilder: (context, index) {
                        return  GestureDetector(
                          onTap: () {
                            if (!widget.isNew)
                              Navigator.push(context, MaterialPageRoute(builder: (context) => AdminEmployeeDetailsPage(employee: employees[index])));
                            else
                              Navigator.push(context, MaterialPageRoute(builder: (context) => AddEmployeePage(employee: employees[index], op: Operation.Add)));

                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 0),
                          //  child: Row(
                            //  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          //    children: [
                                
                                  child: Card(
                                    elevation: 5,
                                    color: AppColors.backgroundColor3,
                                    child: Container(
                                      height: 50,
                                      child: Center(
                                        child: Text(
                                        employees[index].name,
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ) 
                                  ) 
                                ),
                            //  ],
                            ),
                          // )
                        ); 
                      },
                    ),
                  ],
                ),
              ),
            )
          ) 
        ), 
      )
    );
    
  }
}


class CommissionListPage extends StatefulWidget implements FilteredList{
  CommissionListPage({super.key, required  this.isService, this.filter});

  final bool isService;
  final String? filter;

  _CommissionListPageState? state = null;

  @override
  State<CommissionListPage> createState() {
    state = _CommissionListPageState();
    return state!;
  } 

  @override
  Filter? getFilter()
  {
    return state?.queryFilter;
  }

  @override
  void setFilter(Filter filter)
  {
    updateData(queryFilter: filter);
  }
  
  void updateData({Filter? queryFilter = null}){
    state!.rebuild(queryFilter);
  }
}


class _CommissionListPageState extends State<CommissionListPage> {
  
  List<Commission> commissions = List.empty();
    Filter queryFilter = Filter();

  @override
  void initState() {
    updateData();
  }

  // this may cause a problem if one of the lists is empty, not sure, depends on List methods returned value when list is empty
  void updateData(){
    
    Map<String, dynamic> filters = Map<String, dynamic>();
    queryFilter.apply(filters);
    
    if (widget.filter == null)
      getCommissions().then((value) {
        setState(() {
          commissions = value;
        });
      });
      
    else if (widget.isService)
    {
      filters["project.service"] = widget.filter??"";
      
      getCommissions(filters: filters).then((value) {
        setState(() {
          commissions = value;
        });
      });
    }

    else
    {
      filters["employee"] = widget.filter??"";
      
      getCommissions(filters: filters).then((value) {
        setState(() {
          commissions = value;
        });
      });
    }

  }


  void rebuild(Filter? queryFilter_) {
    setState(() {
      if (queryFilter_ != null)
        queryFilter = queryFilter_;
      updateData();
    });
  }


  @override
  Widget build(BuildContext context) {
    return /*Center(
      child:*/ Container(
        color: AppColors.backgroundColor,
        width: 450,
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              color: AppColors.backgroundColor,
              child: Padding(
                padding: const EdgeInsets.only( right: 20, left: 20),
                child: SizedBox(
                  width: 400,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: commissions.length,
                        itemBuilder: (context, index) {
                          return  GestureDetector(
                            onTap: () {
                              Widget? w = context.findAncestorWidgetOfExactType<EmployeeMainPage>();
                              if (w == null)
                                Navigator.push(context, MaterialPageRoute(builder: (context) => CommissionDetailsPage(commission: commissions[index])));
                            },
                            child: Card(
                              elevation: 5,
                              color: AppColors.backgroundColor3,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      height: 30,
                                        child: Center(
                                          child: Text(
                                            DateFormat('yyyy-MM-dd HH:mm:ss').format(commissions[index].date)
                                        ),
                                      ) 
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.only(left: 30),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  commissions[index].project.type,
                                                  style: TextStyle(fontSize: 16),
                                                ),
                                                Text(
                                                  commissions[index].project.name,
                                                  style: TextStyle(fontSize: 25),

                                                ),
                                                Text(commissions[index].project.clientName),
                                                Text(commissions[index].project.clientNumber),
                                              ],
                                            ),
                                          )
                                          
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.only(left: 30),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  commissions[index].project.pay.toString() + " DA",
                                                  style: TextStyle(fontSize: 25),
                                                ),
                                                Text(
                                                  StatusMessage(commissions[index].status),
                                                  style: TextStyle(fontSize: 20),
                                                ),
                                              ],
                                            ),
                                          )
                                        )
                                      ],
                                    ) 
                                  ],
                                ),
                              )
                            )
                          ); 
                        },
                      ),
                    ],
                  ),
                ),
              )
            ) 
          ), 
        ),
      )
   /* )*/;
    
    
    
  }
}



class NewCommissionListPage extends StatefulWidget implements FilteredList{
  NewCommissionListPage({super.key, this.filter});

  final String? filter;
  _NewCommissionListPageState? state = null;

  @override
  State<NewCommissionListPage> createState() {
    state = _NewCommissionListPageState();
    return state!;
  } 

  @override
  Filter? getFilter()
  {
    return state?.queryFilter;
  }

  @override
  void setFilter(Filter filter)
  {
    updateData(queryFilter: filter);
  }
  
  void updateData({Filter? queryFilter}){
    state!.rebuild(queryFilter);
  }
}


class _NewCommissionListPageState extends State<NewCommissionListPage> {
  
  List<NewCommission> commissions = List.empty();
  Filter queryFilter = Filter();

  @override
  void initState() {
    updateData();
  }

  // this may cause a problem if one of the lists is empty, not sure, depends on List methods returned value when list is empty
  void updateData(){

    Map<String, dynamic> filters = Map<String, dynamic>();
    queryFilter.apply(filters);
    
    if (widget.filter == null) {
      getNewCommissions().then((value) {
        setState(() {
          commissions = value;
        });
      });
    }
    
    else {
      filters["employee"] = widget.filter ?? "";
      getNewCommissions(filters: filters).then((value) {
        setState(() {
          commissions = value;
        });
      });
    }

  }

  void rebuild(Filter? queryFilter_) {
    setState(() {
      if( queryFilter_ != null)
        queryFilter = queryFilter_;
      updateData();
    });
  }


  @override
  Widget build(BuildContext context) {
    return  Container(
      color: AppColors.backgroundColor,
      child: SingleChildScrollView(
        child: Center(
          child: Container(
            color: AppColors.backgroundColor,
            child: Padding(
              padding: const EdgeInsets.only( right: 20, left: 20),
              child: SizedBox(
                width: 400,
                child:  Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max ,
                  children: <Widget>[
                    ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: commissions.length,
                      itemBuilder: (context, index) {
                        return  GestureDetector(
                          onTap: () {
                            Widget? w = context.findAncestorWidgetOfExactType<EmployeeMainPage>();
                              if (w == null)
                            Navigator.push(context, MaterialPageRoute(builder: (context) => NewCommissionDetailsPage(commission: commissions[index])));
                          },
                          child: Card(
                            elevation: 5,
                            color: AppColors.backgroundColor3,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child:   Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    height: 30,
                                      child: Center(
                                        child: Text(
                                          DateFormat('yyyy-MM-dd HH:mm:ss').format(commissions[index].date)
                                      ),
                                    ) 
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 30),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                commissions[index].project.service,
                                                style: TextStyle(fontSize: 16),
                                              ),
                                              Text(
                                                commissions[index].project.name,
                                                style: TextStyle(fontSize: 25),

                                              ),
                                              Text(commissions[index].project.clientName),
                                              Text(commissions[index].project.clientNumber),
                                            ],
                                          ),
                                        )
                                        
                                      ),
                                      Expanded(
                                        child:  Padding(
                                          padding: EdgeInsets.only(left: 30),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Facture: " + commissions[index].numeroFacture,
                                                style: TextStyle(fontSize: 15),
                                              ),
                                              Text(
                                                commissions[index].project.pay.toString() + " DA",
                                                style: TextStyle(fontSize: 25),
                                              ),
                                              Text(
                                                StatusMessage(commissions[index].status),
                                                style: TextStyle(fontSize: 20),
                                              ),
                                            ],
                                          ),
                                        )
                                      )
                                      
                                    ],
                                  ) 
                                ],
                              ),
                            )
                          
                          )
                        ); 
                      },
                    ),
                  ],
                ),
              ),
            )
          ) 
        ), 
      )
    );
  }
}



class PaymentListPage extends StatefulWidget{
  PaymentListPage({super.key, this.employee});

  final String? employee;
  _PaymentListPageState? state = null;

  @override
  State<PaymentListPage> createState() {
    state = _PaymentListPageState();
    return state!;
  }


  void updateData({Filter? queryFilter}){
    state!.rebuild(queryFilter);
  }
}

class _PaymentListPageState extends State<PaymentListPage> {
  
  List<FinalPayment> payments = List.empty();

  @override
  void initState() {
    updateData();
  }

  // this may cause a problem if one of the lists is empty, not sure, depends on List methods returned value when list is empty
  void updateData(){
    
    Map<String, String> filters = Map<String, String>();
    
    filters["employee"] = widget.employee??"";
    
    getFinalPayments(filters: filters).then((value) {
      setState(() {
        payments = value;
      });
    });
  }

  void rebuild(Filter? queryFilter_) {
    updateData();
  }

  @override
  Widget build(BuildContext context) {
    return /*Center(
      child:*/ Container(
        color: AppColors.backgroundColor,
        width: 450,
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              color: AppColors.backgroundColor,
              child: Padding(
                padding: const EdgeInsets.only( right: 20, left: 20),
                child: SizedBox(
                  width: 400,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: payments.length,
                        itemBuilder: (context, index) {
                          return  GestureDetector(
                            onTap: () {/*
                              Widget? w = context.findAncestorWidgetOfExactType<EmployeeMainPage>();
                              if (w == null)
                                Navigator.push(context, MaterialPageRoute(builder: (context) => CommissionDetailsPage(commission: commissions[index])));
                          */},
                            child: Card(
                              elevation: 5,
                              color: AppColors.backgroundColor3,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      height: 30,
                                        child: Center(
                                          child: Text(
                                            DateFormat('yyyy-MM-dd HH:mm:ss').format(payments[index].date)
                                        ),
                                      ) 
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Padding(
                                            padding: EdgeInsets.only(left: 30),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Salaire: " + payments[index].details.salary.toString() + " DA",
                                                ),
                                                Text(
                                                  "Commissions: " + payments[index].details.commissions.toString() + " DA",
                                                ),
                                                Text("prépayée: " + payments[index].details.prepaid.toString() + " DA"),
                                                Text("pénalité: " + payments[index].details.penalty.toString() + "DA"),
                                              ],
                                            ),
                                          )
                                          
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Padding(
                                            padding: EdgeInsets.only(left: 30),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  payments[index].details.payed.toString() + " DA",
                                                  style: TextStyle(fontSize: 25),
                                                ),
                                              ],
                                            ),
                                          )
                                        )
                                      ],
                                    ) 
                                  ],
                                ),
                              )
                            )
                          ); 
                        },
                      ),
                    ],
                  ),
                ),
              )
            ) 
          ), 
        ),
      )
   /* )*/;
    
    
    
  }
}