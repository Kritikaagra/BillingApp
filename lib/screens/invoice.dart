import 'dart:typed_data';
import 'package:billing_app/models/customer_model.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/invoice_model.dart';
import '../models/receivable_model.dart';
import '../service/database_service.dart';

List<List<String>>? myNestedListForSell;
List<List<String>>? myNestedListForReceivableItems;
DateFormat formatter = DateFormat('dd-MMM-yyyy hh:mm a');
final formatterNum = NumberFormat('#,##,###.##', 'en_IN');

Future<Uint8List> generateInvoice(CustomerModel customer) async {
  //get sell and receivable items
  List<InvoiceModel> invoiceDetails =
      await DatabaseService.instance.getInvoiceDetails(customer.customerId!);

  List<ItemPurchaseModel> receivableItems =
      await DatabaseService.instance.getReceivable(customer.customerId!);

  //get total fine silver and lab for both
  int totalFineSilverSell = invoiceDetails.fold(
    0,
    (int accumulator, InvoiceModel invoice) =>
        accumulator + invoice.fineSilver!,
  );
  int totalLabourAmountForSell = invoiceDetails.fold(
    0,
    (int accumulator, InvoiceModel invoice) => accumulator + invoice.labourNet!,
  );

  double totalItemWeightForSell = invoiceDetails.fold(
    0.00,
    (double accumulator, InvoiceModel invoice) =>
        accumulator + invoice.itemWeight!.round(),
  );
  int totalNetItemWeightForSell = invoiceDetails.fold(
    0,
    (int accumulator, InvoiceModel invoice) =>
        accumulator +
        (invoice.itemWeight!.round() - invoice.polyWeightinGm!.round()),
  );

  //for receivable
  double totalItemWeightForReceivable = receivableItems.fold(
    0.00,
    (double accumulator, ItemPurchaseModel invoice) =>
        accumulator + invoice.itemWeight!.round(),
  );
  int totalFineSilverReceivable = receivableItems.fold(
    0,
    (int accumulator, ItemPurchaseModel invoice) =>
        accumulator + invoice.fineSilver!,
  );
  int totalLabourAmountForReceivable = receivableItems.fold(
    0,
    (int accumulator, ItemPurchaseModel invoice) =>
        accumulator + invoice.labourNet!,
  );

//add row in nesdted list
  myNestedListForSell = invoiceDetails
      .map((e) => [
            "${e.itemName}\nT${e.itemRate}${e.labourInString!.isEmpty ? "" : '\n${e.labourInString}'}${e.polyWeight!.isEmpty ? "" : '\npp:${e.polyWeight}'}",
            e.itemWeight!.round(),
            "${(e.itemWeight!.round() - e.polyWeightinGm!.round())}",
            e.fineSilver,
            e.labourNet
          ].map((obj) => obj?.toString() ?? '').toList())
      .toList();
  myNestedListForSell?.add([
    "TOTAL",
    totalItemWeightForSell.round().toString(),
    totalNetItemWeightForSell.toString(),
    totalFineSilverSell.toString(),
    totalLabourAmountForSell.toString()
  ]);

  myNestedListForReceivableItems = receivableItems
      .map((e) => [
            "${e.itemName}\nT${e.itemRate}\n${e.labourPerPc == null && e.labourPerKg == null ? "" : e.labourPerPc == null ? ', ${e.labourPerKg!.round()}/kg' : ', ${e.noOfPc}@${e.labourPerPc!.round()}p'}",
            e.itemWeight!.round(),
            e.itemWeight!.round(),
            e.fineSilver,
            e.labourNet
          ].map((obj) => obj?.toString() ?? '').toList())
      .toList();
  myNestedListForReceivableItems?.add([
    "TOTAL",
    totalItemWeightForReceivable.round().toString(),
    totalItemWeightForReceivable.round().toString(),
    totalFineSilverReceivable.toString(),
    totalLabourAmountForReceivable.toString()
  ]);

  final pdf = pw.Document();
  int pdfl = invoiceDetails.length + receivableItems.length;

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat(
          80 * PdfPageFormat.mm, (150 + (pdfl * 40)) * PdfPageFormat.mm),
      build: (pw.Context context) => pw.Container(
        child: pw.SizedBox(
          height: PdfPageFormat.roll80.availableHeight,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("*This is an estimate only",
                  style: const pw.TextStyle(fontSize: 9)),
              pw.SizedBox(height: 8),
              _buildHeader(context, customer),
              invoiceDetails.isEmpty
                  ? pw.Container(height: 0)
                  : pw.Text("Issued:", style: const pw.TextStyle(fontSize: 10)),
              _contentIssueTable(context, invoiceDetails),
              pw.SizedBox(height: 8),
              receivableItems.isEmpty
                  ? pw.Container(height: 0)
                  : pw.Text("Receivable:",
                      style: const pw.TextStyle(fontSize: 10)),
              _contentReceivableTable(context, receivableItems),
              _buildTotalValues(
                  context,
                  customer,
                  (totalItemWeightForSell),
                  (totalFineSilverSell - totalFineSilverReceivable),
                  (totalLabourAmountForSell - totalLabourAmountForReceivable)),
            ],
          ),
        ),
      ),
    ),
  );

  return pdf.save();
}

pw.Widget _buildHeader(pw.Context context, CustomerModel customer) {
  return pw.Container(
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          child: pw.Text("Customer Name : ${customer.customerName!}",
              style: const pw.TextStyle(fontSize: 10)),
        ),
        pw.Container(
          child: pw.Text(
              "Silver Rate : Rs. ${customer.silverRate!.round()} /kg",
              style: const pw.TextStyle(fontSize: 10)),
        ),
        pw.Container(
          child: pw.Text(
              "Purchase Date : ${formatter.format(DateTime.parse(customer.purchaseDate!))}",
              style: const pw.TextStyle(fontSize: 10)),
        ),
        pw.SizedBox(height: 8),
      ],
    ),
  );
}

pw.Widget _contentIssueTable(
    pw.Context context, List<InvoiceModel> invoiceDetails) {
  const tableHeaders = [
    'ITEM',
    'GR',
    'NET',
    'F',
    'L',
  ];
  
  pw.Table issuedTable = pw.Table.fromTextArray(
      border: const pw.TableBorder(
        verticalInside: pw.BorderSide(
          color: PdfColors.grey,
          width: 0.5,
        ),
        horizontalInside: pw.BorderSide(
          color: PdfColors.grey,
          width: 0.5,
        ),
        left: pw.BorderSide(color: PdfColors.grey, width: 0.5),
        right: pw.BorderSide(color: PdfColors.grey, width: 0.5),
        bottom: pw.BorderSide(color: PdfColors.grey, width: 0.5),
      ),
      columnWidths: {
        0: const pw.FixedColumnWidth(14),
        1: const pw.FixedColumnWidth(6),
        2: const pw.FixedColumnWidth(6),
        3: const pw.FixedColumnWidth(6),
        4: const pw.FixedColumnWidth(8),
      },
      tableWidth: pw.TableWidth.max,
      cellAlignment: pw.Alignment.centerLeft,
      headerDecoration: const pw.BoxDecoration(
          border: pw.TableBorder(
        top: pw.BorderSide(color: PdfColors.grey, width: 0.5),
      )),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.centerLeft,
        4: pw.Alignment.centerLeft,
      },
      headerStyle: const pw.TextStyle(
        color: PdfColors.black,
        fontSize: 9,
      ),
      cellStyle: const pw.TextStyle(
        color: PdfColors.black,
        fontSize: 10,
      ),
      headers: List<String>.generate(
        tableHeaders.length,
        (col) => tableHeaders[col],
      ),
      data: myNestedListForSell!);

  return invoiceDetails.isEmpty
      ? pw.Container(height: 0)
      : pw.Container(
          child: issuedTable,
        );
}

pw.Widget _contentReceivableTable(
    pw.Context context, List<ItemPurchaseModel> itemPurchasedList) {
  return itemPurchasedList.isEmpty
      ? pw.Container(height: 0)
      : pw.Container(
          child: pw.Column(children: [
            pw.Table.fromTextArray(
                border: const pw.TableBorder(
                  verticalInside: pw.BorderSide(
                    color: PdfColors.grey,
                    width: 0.5,
                  ),
                  horizontalInside: pw.BorderSide(
                    color: PdfColors.grey,
                    width: 0.5,
                  ),
                  left: pw.BorderSide(color: PdfColors.grey, width: 0.5),
                  right: pw.BorderSide(color: PdfColors.grey, width: 0.5),
                  bottom: pw.BorderSide(color: PdfColors.grey, width: 0.5),
                ),
                tableWidth: pw.TableWidth.max,
                columnWidths: {
                  0: const pw.FixedColumnWidth(14),
                  1: const pw.FixedColumnWidth(6),
                  2: const pw.FixedColumnWidth(6),
                  3: const pw.FixedColumnWidth(6),
                  4: const pw.FixedColumnWidth(8),
                },
                cellAlignment: pw.Alignment.centerLeft,
                headerDecoration: const pw.BoxDecoration(
                    border: pw.TableBorder(
                  top: pw.BorderSide(color: PdfColors.grey, width: 0.5),
                )),
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerLeft,
                  2: pw.Alignment.centerLeft,
                  3: pw.Alignment.centerLeft,
                  4: pw.Alignment.centerLeft,
                },
                headerStyle: const pw.TextStyle(
                  color: PdfColors.black,
                  fontSize: 9,
                ),
                cellStyle: const pw.TextStyle(
                  color: PdfColors.black,
                  fontSize: 10,
                ),
                data: myNestedListForReceivableItems!),
            pw.SizedBox(height: 10),
          ]),
        );
}

pw.Widget _buildTotalValues(pw.Context context, CustomerModel customer,
    double totalItemWeight, int totalFineSilver, int totalLabourAmount) {
  return pw.Container(
      child:
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
    pw.Container(
      child: pw.Text(
          "Total Gross Weight: ${formatterNum.format(totalItemWeight)}gm",
          style: const pw.TextStyle(fontSize: 10)),
    ),
    pw.Container(
      child: pw.Text(
          "Total Fine Silver : ${formatterNum.format(totalFineSilver)}gm",
          style: const pw.TextStyle(fontSize: 10)),
    ),
    pw.Container(
      child: pw.Text(
          "Total Labour Amount : Rs. ${formatterNum.format(totalLabourAmount)}",
          style: const pw.TextStyle(fontSize: 10)),
    ),
    pw.SizedBox(height: 5),
    pw.Container(
      child: pw.Text(
          "Net Amount : Rs. ${formatterNum.format((totalFineSilver * (customer.silverRate! / 1000)).round() + (totalLabourAmount))}",
          style: const pw.TextStyle(fontSize: 10)),
    ),
  ]));
}
