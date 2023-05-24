import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../models/receivable_model.dart';
import '../service/database_service.dart';
import 'package:billing_app/models/customer_model.dart';
import 'package:billing_app/screens/item_sell_form.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:billing_app/screens/item_purchase_form.dart';

final formatter = NumberFormat('#,##0.00', 'en_US');

// ignore: must_be_immutable
class InvoiceReceivedPreview extends StatefulWidget {
  InvoiceReceivedPreview({super.key, required this.customer});

  CustomerModel customer;

  @override
  // ignore: library_private_types_in_public_api
  _InvoiceReceivedPreviewState createState() => _InvoiceReceivedPreviewState();
}

class _InvoiceReceivedPreviewState extends State<InvoiceReceivedPreview> {
  List<ItemPurchaseModel> receivableList = <ItemPurchaseModel>[];
  final DataGridController _receivabledataGridController = DataGridController();
  late ReceivableData _receivableDataGridSource =
      ReceivableData(receivable: receivableList);
  int index = -1; 

  Future<void> getInvoiceData() async {
    List<ItemPurchaseModel> receivableItems = await DatabaseService.instance
        .getReceivable(widget.customer.customerId!);
    setState(() {
      receivableList = receivableItems;
      _receivableDataGridSource = ReceivableData(receivable: receivableList);
    });
  }

  @override
  void initState() {
    super.initState();
    getInvoiceData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ItemForm(customer: widget.customer)));
            },
            icon: const Icon(Icons.add, size: 30),
          ),
        ],
      ),
      body: receivableList.isEmpty
          ? const Center(child: Text("Nothing in Receivables"))
          : SfDataGrid(
              onQueryRowHeight: (details) {
                if (details.rowIndex == 0) {
                  return 0;
                }
                return details.getIntrinsicRowHeight(details.rowIndex);
              },
              isScrollbarAlwaysShown: true,
              headerRowHeight: 0,
              source: _receivableDataGridSource,
              controller: _receivabledataGridController,
              selectionMode: SelectionMode.singleDeselect,
              allowSwiping: true,
              swipeMaxOffset: 80.0,
              endSwipeActionsBuilder:
                  (BuildContext context, DataGridRow row, int rowIndex) {
                return GestureDetector(
                    onTap: () async {
                      await DatabaseService.instance
                          .deleteRecevable(
                              receivableList[rowIndex].receivableId!)
                          .then((value) => {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text("Successfully Deleted!"),
                                  duration: Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                  margin: EdgeInsets.all(20),
                                ))
                              });
                      _receivableDataGridSource.dataGridRows.removeAt(rowIndex);
                      _receivableDataGridSource.updateDataGridSource();
                    },
                    child: Container(
                        color: const Color.fromARGB(255, 228, 57, 45),
                        child: const Center(
                          child: Icon(Icons.delete),
                        )));
              },
              columns: [
                GridColumn(
                    columnName: 'item',
                    minimumWidth: 140,
                    label: Container(
                        alignment: Alignment.centerLeft,
                        child: const Text('ITEM'))),
                GridColumn(
                    columnName: 'gross',
                    label: Container(
                        alignment: Alignment.centerLeft,
                        child: const Text('G'))),
                GridColumn(
                    columnName: 'netWeight',
                    label: Container(
                        alignment: Alignment.centerLeft,
                        child: const Text('NET'))),
                GridColumn(
                    columnName: 'silver',
                    label: Container(
                        alignment: Alignment.centerLeft,
                        child: const Text('F'))),
                GridColumn(
                    columnName: 'labour',
                    label: Container(
                        alignment: Alignment.centerLeft,
                        child: const Text('L'))),
              ],
              onSelectionChanged:
                  (List<DataGridRow> addedRows, List<DataGridRow> removedRows) {
                if (addedRows.isNotEmpty) {
                  index = _receivableDataGridSource.dataGridRows
                      .indexOf(addedRows.last);

                  Navigator.pop(context);
                  _receivabledataGridController.selectedRow != null
                      ? Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ItemPurchaseForm(
                                    customer: widget.customer,
                                    editItem: receivableList[index],
                                  )))
                      : null;
                }
              },
            ),
    );
  }
}

class ReceivableData extends DataGridSource {
  ReceivableData({required List<ItemPurchaseModel> receivable}) {
    dataGridRows = receivable
        .map<DataGridRow>((e) => DataGridRow(
              cells: [
                DataGridCell<String>(
                  columnName: 'item',
                  value:
                      "${e.itemName}, \nT${e.itemRate}${e.labourPerPc == null && e.labourPerKg == null ? "" : e.labourPerPc == null ? ', ${e.labourPerKg!.round()}/kg' : ', ${e.noOfPc}@${e.labourPerPc!.round()}p'}",
                ),
                DataGridCell<String>(
                    columnName: 'gross',
                    value: e.itemWeight!.round().toString()),
                DataGridCell<String>(
                    columnName: 'netWeight',
                    value: e.itemWeight!.round().toString()),
                DataGridCell<String>(
                    columnName: 'silver', value: e.fineSilver.toString()),
                DataGridCell<String>(
                    columnName: 'labour', value: e.labourNet.toString())
              ],
            ))
        .toList();
  }

  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {
      return Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          child: Text(
            dataGridCell.value.toString(),
            overflow: TextOverflow.visible,
          ));
    }).toList());
  }

  void updateDataGridSource() {
    notifyListeners();
  }
}
