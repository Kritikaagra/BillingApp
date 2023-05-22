import 'package:billing_app/models/customer_model.dart';
import 'package:billing_app/models/invoice_model.dart';
import 'package:billing_app/screens/item_purchase_form.dart';
import 'package:billing_app/screens/item_sell_form.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../models/receivable_model.dart';
import '../service/database_service.dart';

final formatter = NumberFormat('#,##0.00', 'en_US');

// ignore: must_be_immutable
class InvoicePreview extends StatefulWidget {
  InvoicePreview({super.key, required this.customer});

  CustomerModel customer;

  @override
  // ignore: library_private_types_in_public_api
  _InvoicePreviewState createState() => _InvoicePreviewState();
}

class _InvoicePreviewState extends State<InvoicePreview> {
  List<InvoiceModel> _employees = <InvoiceModel>[];
  List<ItemPurchaseModel> receivableList = <ItemPurchaseModel>[];
  late EmployeeDataGridSource _employeeDataGridSource =
      EmployeeDataGridSource(employees: _employees);
  final DataGridController _dataGridController = DataGridController();
  final DataGridController _receivabledataGridController = DataGridController();

  late ReceivableData _receivableDataGridSource =
      ReceivableData(receivable: receivableList);

  int index = -1;

  Future<void> getInvoiceData() async {
    List<InvoiceModel> invoiceDetails = await DatabaseService.instance
        .getInvoiceDetails(widget.customer.customerId!);

    List<ItemPurchaseModel> receivableItems = await DatabaseService.instance
        .getReceivable(widget.customer.customerId!);

    setState(() {
      _employees = invoiceDetails;
      _employeeDataGridSource = EmployeeDataGridSource(employees: _employees);

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
        body: SingleChildScrollView(
            child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Issued: ", style: TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              SfDataGrid(
                onQueryRowHeight: (details) {
                  if (details.rowIndex == 0) {
                    return 0;
                  }
                  return details.getIntrinsicRowHeight(details.rowIndex);
                },
                isScrollbarAlwaysShown: true,
                source: _employeeDataGridSource,
                controller: _dataGridController,
                selectionMode: SelectionMode.singleDeselect,
                allowSwiping: true,
                swipeMaxOffset: 80.0,
                endSwipeActionsBuilder:
                    (BuildContext context, DataGridRow row, int rowIndex) {
                  return GestureDetector(
                      onTap: () async {
                        await DatabaseService.instance
                            .deleteInvoiceId(_employees[rowIndex].invoiceId!)
                            .then((value) => {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content: Text("Successfully Deleted!"),
                                    duration: Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                  margin: EdgeInsets.all(20),
                                  ))
                                });
                        _employeeDataGridSource.dataGridRows.removeAt(rowIndex);
                        _employeeDataGridSource.updateDataGridSource();
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
                      columnWidthMode: ColumnWidthMode.none,
                      minimumWidth: 200,
                      label: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          alignment: Alignment.centerLeft,
                          child: const Text('ITEM'))),
                  GridColumn(
                      columnName: 'silver',
                      columnWidthMode: ColumnWidthMode.fitByColumnName,
                      label: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            'FINE SILVER (gm)',
                          ))),
                  GridColumn(
                      columnName: 'labour',
                      columnWidthMode: ColumnWidthMode.fitByColumnName,
                      label: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            'LABOUR AMOUNT (Rs.)',
                          ))),
                ],
                onSelectionChanged: (List<DataGridRow> addedRows,
                    List<DataGridRow> removedRows) {
                  if (addedRows.isNotEmpty) {
                    if (_receivabledataGridController.selectedRow != null) {
                      _receivabledataGridController.selectedRow = null;
                    }
                    index = _employeeDataGridSource.dataGridRows
                        .indexOf(addedRows.last);
                    Navigator.pop(context);
                    _dataGridController.selectedRow == null
                        ? Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => ItemPurchaseForm(
                                      customer: widget.customer,
                                      editItem: receivableList[index],
                                    )))
                        : Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => ItemForm(
                                      customer: widget.customer,
                                      editItem: _employees[index],
                                    )));
                  }
                },
              ),
              const SizedBox(height: 30),
              receivableList.isNotEmpty
                  ? const Text("Receivable: ", style: TextStyle(fontSize: 18))
                  : const SizedBox(height: 0),
              const SizedBox(height: 10),
              SfDataGrid(
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
                        _receivableDataGridSource.dataGridRows
                            .removeAt(rowIndex);
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
                      columnWidthMode: ColumnWidthMode.none,
                      minimumWidth: 200,
                      label: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          alignment: Alignment.centerLeft,
                          child: const Text('ITEM'))),
                  GridColumn(
                      columnName: 'silver',
                      columnWidthMode: ColumnWidthMode.fitByColumnName,
                      label: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          alignment: Alignment.centerLeft,
                          child: const Text('FINE SILVER (gm)'))),
                  GridColumn(
                      columnName: 'labour',
                      columnWidthMode: ColumnWidthMode.fitByColumnName,
                      label: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          alignment: Alignment.centerLeft,
                          child: const Text('LABOUR AMOUNT (Rs.)'))),
                ],
                onSelectionChanged: (List<DataGridRow> addedRows,
                    List<DataGridRow> removedRows) {
                  if (addedRows.isNotEmpty) {
                    if (_dataGridController.selectedRow != null) {
                      _dataGridController.selectedRow = null;
                    }
                    index = _receivableDataGridSource.dataGridRows
                        .indexOf(addedRows.last);

                    Navigator.pop(context);
                    _dataGridController.selectedRow == null
                        ? Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => ItemPurchaseForm(
                                      customer: widget.customer,
                                      editItem: receivableList[index],
                                    )))
                        : Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => ItemForm(
                                      customer: widget.customer,
                                      editItem: _employees[index],
                                    )));
                  }
                },
              ),
            ],
          ),
        )));
  }
}

class EmployeeDataGridSource extends DataGridSource {
  EmployeeDataGridSource({required List<InvoiceModel> employees}) {
    dataGridRows = employees
        .map<DataGridRow>((e) => DataGridRow(
              cells: [
                DataGridCell<String>(
                  columnName: 'item',
                  value:
                      "${e.itemName} \nT${e.itemRate}${e.labourPerPc == null && e.labourPerKg == null ? "" : e.labourPerPc == null ? ', ${e.labourPerKg!.toInt()}/kg' : ', ${e.noOfPc}@${e.labourPerPc!.toInt()}p'}\nGross: ${e.itemWeight!.toInt()} g${e.polyWeight!.isEmpty ? "" : '\npp: ${e.polyWeight}'}",
                ),
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
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

class ReceivableData extends DataGridSource {
  ReceivableData({required List<ItemPurchaseModel> receivable}) {
    dataGridRows = receivable
        .map<DataGridRow>((e) => DataGridRow(
              cells: [
                DataGridCell<String>(
                  columnName: 'item',
                  value:
                      "${e.itemName}, \nT${e.itemRate}${e.labourPerPc == null && e.labourPerKg == null ? "" : e.labourPerPc == null ? ', ${e.labourPerKg!.toInt()}/kg' : ', ${e.noOfPc}@${e.labourPerPc!.toInt()}p'}\nGross: ${e.itemWeight!.toInt()} g",
                ),
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
