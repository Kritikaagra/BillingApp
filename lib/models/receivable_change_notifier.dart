import 'package:billing_app/models/receivable_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:billing_app/service/database_service.dart';

class ReceivableChangeNotifier extends ChangeNotifier {
    final DatabaseService dbClient = DatabaseService.instance;

  Future<void> insertReceivable(ItemPurchaseModel receivableItem, {int? receivableId}) async {
      await dbClient.insertReceivable(receivableItem, receivableId);
  }

  Future<void> deleteRecevable(int receivableId) async {
    await dbClient.deleteRecevable(receivableId);
  }
}