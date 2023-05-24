import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../service/database_service.dart';
import 'package:billing_app/models/invoice_model.dart';
import 'package:billing_app/models/customer_model.dart';
import 'package:billing_app/screens/item_sell_form.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

final formatter = NumberFormat('#,##0.00', 'en_US');

// ignore: must_be_immutable
class InvoiceIssuedPreview extends StatefulWidget {
  InvoiceIssuedPreview({super.key, required this.customer});

  CustomerModel customer;

  @override
  // ignore: library_private_types_in_public_api
  _InvoiceIssuedPreviewState createState() => _InvoiceIssuedPreviewState();
}

class _InvoiceIssuedPreviewState extends State<InvoiceIssuedPreview> {
  List<InvoiceModel> _employees = <InvoiceModel>[];
  late EmployeeDataGridSource _employeeDataGridSource =
      EmployeeDataGridSource(employees: _employees);
  final DataGridController _dataGridController = DataGridController();
  int index = -1;

  Future<void> getInvoiceData() async {
    List<InvoiceModel> invoiceDetails = await DatabaseService.instance
        .getInvoiceDetails(widget.customer.customerId!);
    setState(() {
      _employees = invoiceDetails;
      _employeeDataGridSource = EmployeeDataGridSource(employees: _employees);
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
      body: _employees.isEmpty ? const Center(child: Text("Nothing in Issued Section")):
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
                onSelectionChanged: (List<DataGridRow> addedRows,
                    List<DataGridRow> removedRows) {
                  if (addedRows.isNotEmpty) {
                    index = _employeeDataGridSource.dataGridRows
                        .indexOf(addedRows.last);
                    Navigator.pop(context);
                    _dataGridController.selectedRow == null ? null
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
          );
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
                      "${e.itemName}\nT${e.itemRate}${e.labourInString!.isEmpty ? "" : '\n${e.labourInString}'}${e.polyWeight!.isEmpty ? "" : '\npp: ${e.polyWeight}'}",
                ),
                DataGridCell<String>(
                    columnName: 'gross',
                    value: e.itemWeight!.round().toString()),
                DataGridCell<String>(
                    columnName: 'netWeight',
                    value:
                        "${(e.itemWeight!.round() - e.polyWeightinGm!.round())}"),
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