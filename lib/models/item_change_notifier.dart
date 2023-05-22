import 'package:flutter/cupertino.dart';
import 'package:billing_app/service/database_service.dart';
import 'item_result_model.dart';

class ItemChangeNotifier extends ChangeNotifier {
    final DatabaseService dbClient = DatabaseService.instance;

  Future<List<ItemResultModel>> getAllItem() async {
     return await dbClient.getItemList();
  }
}