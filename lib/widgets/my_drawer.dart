import 'package:billing_app/main.dart';
import 'package:billing_app/screens/view_all_invoice.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text("Bill Generator", style: TextStyle(fontSize: 26, color: Colors.white)),
          ),
          ListTile(
            title: const Text("Home"),
            leading: const Icon(Icons.home),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const MyHomePage()));
            },
          ),
          ListTile(
            title: const Text("All Invoice"),
            leading: const Icon(Icons.remove_red_eye),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const ViewAllInvoice()));
            },
          ),
          // ListTile(
          //   title: const Text("Manage Parties"),
          //   leading: const Icon(Icons.add),
          //   onTap: () {
          //     Navigator.pop(context);
          //     Navigator.push(context,
          //         MaterialPageRoute(builder: (_) => const PartiesPage()));
          //     // Navigator.pop(context);
          //   },
          // ),
          // ListTile(
          //   title: const Text("Manage Invoices"),
          //   leading: const Icon(Icons.add),
          //   onTap: () {
          //     Navigator.pop(context);
          //     Navigator.push(context,
          //         MaterialPageRoute(builder: (_) => const InvoicePage()));
          //     // Navigator.pop(context);
          //   },
          //),
        ],
      ),
    );
  }
}