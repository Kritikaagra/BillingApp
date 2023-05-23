import 'package:billing_app/screens/item_sell_form.dart';
import 'package:billing_app/widgets/my_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/customer_change_notifier.dart';
import 'models/customer_model.dart';
import 'models/invoice_change_notifier.dart';
import 'models/item_change_notifier.dart';
import 'models/receivable_change_notifier.dart'; 
   

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CustomerChangeNotifier()),
          ChangeNotifierProvider(create: (_) => InvoiceChangeNotifier()),
          ChangeNotifierProvider(create: (_) => ItemChangeNotifier()),
          ChangeNotifierProvider(create: (_) => ReceivableChangeNotifier())
        ],
        child: MaterialApp(
          title: 'Bill Generator',
          debugShowCheckedModeBanner: false,
          theme: ThemeData( 
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: const MyHomePage(),
        ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _silverRateController = TextEditingController();
  bool isLoad = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("HomePage"),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _customerNameController,
                    keyboardType: TextInputType.name,
                    decoration: const InputDecoration(
                        labelText: "Customer Name",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(15)),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please enter customer name";
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _silverRateController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                        labelText: "Silver Rate",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(15)),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please enter current silver rate";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          isLoad = true;
                        });
                        var customer = CustomerModel(
                            customerName:
                                _customerNameController.text.toUpperCase(),
                            silverRate:
                                double.parse(_silverRateController.text),
                            purchaseDate: DateTime.now().toString());

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ItemForm(
                                    customer: customer,
                                  )),
                        );
                        setState(() {
                          isLoad = false;
                        });
                      }
                    },
                    child: const Text('START',
                        style: TextStyle(color: Colors.white),
                        textScaleFactor: 1.6),
                  ),
                ],
              ),
            ),
          ),
        ),
        drawer: const MyDrawer());
  }
}
