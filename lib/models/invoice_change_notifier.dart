import 'package:flutter/cupertino.dart';
import 'package:billing_app/service/database_service.dart';
import 'invoice_model.dart';
import 'item_model.dart';

class InvoiceChangeNotifier extends ChangeNotifier {
    final DatabaseService dbClient = DatabaseService.instance;

  Future<void> add(InvoiceModel invoice, ItemModel item, {int? invoiceId}) async {
     await dbClient.insertInvoiceDetails(invoice, item, invoiceId);
  }

  Future<List<InvoiceModel>> getInvoice(int customerId) async {
    return await dbClient.getInvoiceDetails(customerId);
  }
}