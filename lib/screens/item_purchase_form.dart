import 'package:billing_app/screens/invoice_preview.dart';
import 'package:billing_app/screens/item_sell_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import '../models/customer_change_notifier.dart';
import '../models/customer_model.dart';
import '../models/item_change_notifier.dart';
import '../models/receivable_change_notifier.dart';
import '../models/receivable_model.dart';
import '../models/item_result_model.dart';
import 'invoice.dart';

// ignore: must_be_immutable
class ItemPurchaseForm extends StatefulWidget {
  ItemPurchaseForm({Key? key, required this.customer, this.editItem})
      : super(key: key);
  CustomerModel customer;
  ItemPurchaseModel? editItem;
  @override
  State<ItemPurchaseForm> createState() => _ItemPurchaseFormState();
}

class _ItemPurchaseFormState extends State<ItemPurchaseForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemWeightController = TextEditingController();
  final TextEditingController _itemRateController = TextEditingController();
  final TextEditingController _labourControllerPerKg = TextEditingController();
  final TextEditingController _labourControllerPerPc = TextEditingController();
  final TextEditingController _noOfPcController = TextEditingController();
  List<ItemResultModel> allItemData = [];
  bool isLoad = false, isNoOfPcIsVisible = false;

  void fetchSimilarItem() {
    Provider.of<ItemChangeNotifier>(context, listen: false)
        .getAllItem()
        .then((value) {
      setState(() {
        allItemData = value;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    fetchSimilarItem();

    if (widget.editItem != null) {
      _itemNameController.text = widget.editItem!.itemName.toString();
      _itemWeightController.text = widget.editItem!.itemWeight.toString();
      _itemRateController.text = widget.editItem!.itemRate.toString();
      _labourControllerPerKg.text = widget.editItem!.labourPerKg == null
          ? ""
          : widget.editItem!.labourPerKg.toString();
      _labourControllerPerPc.text = widget.editItem!.labourPerPc == null
          ? ""
          : widget.editItem!.labourPerPc.toString();
      if (widget.editItem!.noOfPc != null) {
        setState(() {
          isNoOfPcIsVisible = true;
          _noOfPcController.text = widget.editItem!.noOfPc.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _itemWeightController.dispose();
    _itemRateController.dispose();
    _labourControllerPerKg.dispose();
    _labourControllerPerPc.dispose();
    _noOfPcController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text("Item Return Form"),
        actions: <Widget>[
          Visibility(
            visible: widget.editItem == null ? true : false,
            child: TextButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ItemForm(
                              customer: widget.customer,
                            )));
              },
              child: const Text(
                "Sell",
                textScaleFactor: 1.4,
                style: TextStyle(color: Color.fromARGB(255, 10, 45, 99)),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 20),
              TypeAheadFormField(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: _itemNameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(15),
                    labelText: "Item",
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Required";
                  }
                  return null;
                },
                suggestionsCallback: (String pattern) async {
                  List<String> itemNames =
                      allItemData.map((e) => e.itemName!.trim()).toList();
                  itemNames.sort((a, b) => a.compareTo(b));
                  if (pattern.trim().isEmpty) {
                    return const Iterable<String>.empty();
                  }
                  return itemNames.where((String option) {
                    return option.contains(pattern.trim().toUpperCase());
                  });
                },
                itemBuilder: (context, String suggestion) {
                  return ListTile(
                    title: Text(suggestion),
                  );
                },
                onSuggestionSelected: (String suggestion) {
                  _itemNameController.text = suggestion.trim();
                },
                noItemsFoundBuilder: (context) {
                  return Container(
                    height: 0,
                  );
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _itemWeightController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                    labelText: "Net Weight (in gm)",
                    contentPadding: EdgeInsets.all(15),
                    border: OutlineInputBorder()),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Required";
                  } else if (double.parse(value) == 0.0) {
                    return "Weight must be greater than zero";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: _itemRateController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                          labelText: "Item Rate (in %)",
                          contentPadding: EdgeInsets.all(15),
                          border: OutlineInputBorder()),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Required";
                        } 
                        // else if (double.parse(value) < 40.0) {
                        //   return "Rate must be greater than 40%";
                        // }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "%",
                    style: TextStyle(fontSize: 23),
                  )
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: _labourControllerPerKg,
                      onChanged: (value) => {
                        setState(() {
                          isNoOfPcIsVisible = false;
                        }),
                        _labourControllerPerPc.text.isNotEmpty
                            ? _labourControllerPerPc.text = ""
                            : null,
                      },
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                          labelText: "Labour (per kg)",
                          contentPadding: EdgeInsets.all(15),
                          border: OutlineInputBorder()),
                      // validator: (value) {
                      //   if (value!.isEmpty &&
                      //       _labourControllerPerPc.text.isEmpty) {
                      //     return "Required at least one type of labour charge";
                      //   }
                      //   return null;
                      // },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _labourControllerPerPc,
                      onChanged: (value) => {
                        setState(() {
                          isNoOfPcIsVisible = true;
                        }),
                        _labourControllerPerKg.text.isNotEmpty
                            ? _labourControllerPerKg.text = ""
                            : null,
                      },
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                          labelText: "Labour (per Pc)",
                          contentPadding: EdgeInsets.all(15),
                          border: OutlineInputBorder()),
                      // validator: (value) {
                      //   if (value!.isEmpty &&
                      //       _labourControllerPerKg.text.isEmpty) {
                      //     return "Required at least one type of labour charge";
                      //   }
                      //   return null;
                      // },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Visibility(
                visible: isNoOfPcIsVisible,
                child: TextFormField(
                  controller: _noOfPcController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                      labelText: "No of Piece",
                      contentPadding: EdgeInsets.all(15),
                      border: OutlineInputBorder()),
                  validator: (value) {
                    if (value!.isEmpty || int.parse(value) == 0) {
                      return "Required";
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          isLoad = true;
                        });
                        if (widget.customer.customerId == null) {
                          await Provider.of<CustomerChangeNotifier>(context,
                                  listen: false)
                              .add(widget.customer)
                              .then((value) {
                            widget.customer = value;
                            setState(() {
                              isLoad = false;
                            });
                          });
                        }

                        int labourNet = (_labourControllerPerKg.text.isEmpty &&
                                _labourControllerPerPc.text.isNotEmpty
                            ? (double.parse(_labourControllerPerPc.text) *
                                    int.parse(_noOfPcController.text))
                                .round()
                            : (_labourControllerPerKg.text.isEmpty &&
                                    _labourControllerPerPc.text.isEmpty
                                ? 0
                                : ((double.parse(_labourControllerPerKg.text) /
                                            1000) *
                                        double.parse(
                                            _itemWeightController.text))
                                    .round()));

                        var itemPurchased = ItemPurchaseModel(
                            receivableId: widget.editItem != null
                                ? widget.editItem!.receivableId
                                : null,
                            customerId: widget.customer.customerId!,
                            itemName: _itemNameController.text.toUpperCase(),
                            itemWeight:
                                double.parse(_itemWeightController.text),
                            itemRate: double.parse(_itemRateController.text),
                            fineSilver: (double.parse(
                                        _itemWeightController.text) *
                                    (double.parse(_itemRateController.text) /
                                        100))
                                .round(),
                            labourPerKg: _labourControllerPerKg.text.isEmpty
                                ? null
                                : double.parse(_labourControllerPerKg.text),
                            labourPerPc: _labourControllerPerPc.text.isEmpty
                                ? null
                                : double.parse(_labourControllerPerPc.text),
                            labourNet: labourNet);

                        widget.editItem != null
                            // ignore: use_build_context_synchronously
                            ? await Provider.of<ReceivableChangeNotifier>(
                                    context,
                                    listen: false)
                                .insertReceivable(itemPurchased,
                                    receivableId: widget.editItem!.receivableId)
                                .then((value) {
                                setState(() {
                                  isLoad = false;
                                });
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        InvoicePreview(
                                      customer: widget.customer,
                                    ),
                                  ),
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text("Item Updated!"),
                                  duration: Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                  margin: EdgeInsets.all(20),
                                ));
                              })
                            :
                            // ignore: use_build_context_synchronously
                            await Provider.of<ReceivableChangeNotifier>(context,
                                    listen: false)
                                .insertReceivable(itemPurchased)
                                .then((value) {
                                setState(() {
                                  isLoad = false;
                                });
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        ItemPurchaseForm(
                                      customer: widget.customer,
                                    ),
                                  ),
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text("Item Received!"),
                                  duration: Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                  margin: EdgeInsets.all(20),
                                ));
                              });
                      }
                    },
                    child: const Text(
                      'Add item',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent),
                    onPressed: () async {
                      if (widget.customer.customerId != null) {
                        await Printing.layoutPdf(
                            format: PdfPageFormat.roll80,
                          onLayout: (_) => generateInvoice(widget.customer));
                      } else {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("Add at least one item!"),
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.all(20),
                        ));
                      }
                    },
                    child: const Text(
                      'Finalize',
                      style: TextStyle(
                          color: Colors.white,
                          backgroundColor: Colors.redAccent),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
