import 'package:billing_app/models/customer_model.dart';
import 'package:billing_app/screens/invoice.dart';
import 'package:billing_app/screens/invoice_issuedPreview.dart';
import 'package:billing_app/widgets/my_drawer.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/customer_change_notifier.dart';
import 'invoice_receivedPreview.dart';

class ViewAllInvoice extends StatefulWidget {
  const ViewAllInvoice({super.key});

  @override
  State<ViewAllInvoice> createState() => _ViewAllInvoiceState();
}

class _ViewAllInvoiceState extends State<ViewAllInvoice> {
  List<CustomerModel> allCustomerDetails = [];
  @override
  void initState() {
    super.initState();
    fetchSimilarItem();
  }

  void fetchSimilarItem() {
    Provider.of<CustomerChangeNotifier>(context, listen: false)
        .getCustomerList()
        .then((value) {
      setState(() {
        allCustomerDetails = value;
        allCustomerDetails
            .sort((a, b) => b.customerId!.compareTo(a.customerId!));
      });
    });
  }

  DateFormat formatter = DateFormat('dd-MMM-yyyy');
  DateFormat formatter1 = DateFormat('hh:mm:ss a');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Invoice"),
      ),
      body: ListView.builder(
        itemCount: allCustomerDetails.length,
        itemBuilder: (BuildContext context, int index) {
          CustomerModel customer = allCustomerDetails[index];
          return ListTile(
            minVerticalPadding: 13,
            title: Text(customer.customerName!),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("\u20B9 ${customer.silverRate}"),
                Text(formatter.format(DateTime.parse(customer.purchaseDate!))),
                Text(formatter1.format(DateTime.parse(customer.purchaseDate!))),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.print,
                  ),
                  onPressed: () async {
                    await Printing.layoutPdf(
                        format: PdfPageFormat.roll80,
                        onLayout: (_) => generateInvoice(customer));
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.edit,
                  ),
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InvoiceIssuedPreview(
                          customer: customer,
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.r_mobiledata_outlined,
                    size: 40,
                  ),
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InvoiceReceivedPreview(
                          customer: customer,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            // onTap: () async {
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder: (context) => InvoicePreview(
            //         customer: customer,
            //       ),
            //     ),
            //   );
            // },
          );
        },
      ),
      drawer: const MyDrawer(),
    );
  }
}
