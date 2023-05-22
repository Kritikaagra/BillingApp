import 'package:flutter/cupertino.dart';
import 'package:billing_app/service/database_service.dart';
import 'customer_model.dart';

class CustomerChangeNotifier extends ChangeNotifier {
  final DatabaseService dbClient = DatabaseService.instance;

  Future<CustomerModel> add(CustomerModel customer) async {
    CustomerModel customerNew =  await dbClient.insertCustomerDetails(customer);
    return customerNew;
  }

  Future<List<CustomerModel>> getCustomerList() async{
    return await dbClient.getCustomerList();
  }
}