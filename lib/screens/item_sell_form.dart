import 'package:billing_app/screens/invoice_preview.dart';
import 'package:billing_app/screens/item_purchase_form.dart';
import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';
import '../models/item_model.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import '../models/customer_change_notifier.dart';
import '../models/customer_model.dart';
import '../models/invoice_change_notifier.dart';
import '../models/invoice_model.dart';
import '../models/item_change_notifier.dart';
import '../models/item_result_model.dart';
import 'invoice.dart';
import 'package:pdf/pdf.dart';

class _GroupControllers {
  final TextEditingController _polyNoController = TextEditingController();
  final TextEditingController _polyWtController = TextEditingController();
  void dispose() {
    _polyNoController.dispose();
    _polyWtController.dispose();
  }
}

class _GroupControllersForLabour {
  final TextEditingController _netWeightController = TextEditingController();
  final TextEditingController _labourInKgController = TextEditingController();
  void dispose() {
    _netWeightController.dispose();
    _labourInKgController.dispose();
  }
}

// ignore: must_be_immutable
class ItemForm extends StatefulWidget {
  ItemForm({Key? key, required this.customer, this.editItem}) : super(key: key);

  CustomerModel customer;
  InvoiceModel? editItem;
  @override
  State<ItemForm> createState() => _ItemFormState();
}

class _ItemFormState extends State<ItemForm> {
  final List<_GroupControllers> _groupControllers = [];
  final List<TextFormField> _polyNoFields = [];
  final List<TextFormField> _polyWtFields = [];
  final List<_GroupControllersForLabour> _groupControllersLabour = [];
  final List<TextFormField> _netWeightFields = [];
  final List<TextFormField> _labourInKgFields = [];
  final List<int> toggleSwitch = [];

  void getAllPolytheneData(String polyWeights) {
    RegExp regex = RegExp(r"([-+]?[0-9]*\.?[0-9]+)@([-+]?[0-9]*\.?[0-9]+)");

    Iterable<RegExpMatch> matches = regex.allMatches(polyWeights);

    if (matches.isNotEmpty) {
      polyNumberControler.text = matches.first.group(1)!;
      polyWeightController.text = matches.first.group(2)!;
    }

    for (int i = 1; i < matches.length; i++) {
      RegExpMatch match = matches.elementAt(i);
      _addTileOnPressedFunction();
      _groupControllers.elementAt(i - 1)._polyNoController.text =
          match.group(1)!;
      _groupControllers.elementAt(i - 1)._polyWtController.text =
          match.group(2)!;
    }
  }

  void getAllLabourDataToEdit(String labourDetails) {
    RegExp regex = RegExp(r"([-+]?[0-9]*\.?[0-9]+)@([-+]?[0-9]*\.?[0-9]+)/kg");
    Iterable<RegExpMatch> matches = regex.allMatches(labourDetails);

    for (int i = 0 ; i < matches.length; i++) {
      RegExpMatch match = matches.elementAt(i);
      if(i>0) _addTilesForLabour();
      _groupControllersLabour[i]._netWeightController.text = match.group(1)!;
      _groupControllersLabour[i]._labourInKgController.text = match.group(2)!;
    }

    RegExp regex1 = RegExp(r"([-+]?[0-9]*\.?[0-9]+)@([-+]?[0-9]*\.?[0-9]+)/pc");
    Iterable<RegExpMatch> matches1 = regex1.allMatches(labourDetails);

    for (int i = 0; i < matches1.length; i++) {
      RegExpMatch match = matches1.elementAt(i); 
      if(matches.length+i > 0) _addTilesForLabour();
      onToggleFunction(1, matches.length + i);
      _groupControllersLabour[matches.length + i]._netWeightController.text = match.group(1)!;
      _groupControllersLabour[matches.length + i]._labourInKgController.text = match.group(2)!;
      
    }
  }

  @override
  void initState() {
    super.initState();
    fetchSimilarItem();

    final groupLabour = _GroupControllersForLabour();

    final netWeightField = _generateTextFieldForLabour(
        groupLabour._netWeightController, "Net Weight");
    final labourField = _generateTextFieldForLabour(
        groupLabour._labourInKgController, "Labour (/kg)");

    setState(() {
      toggleSwitch.add(0);
      _groupControllersLabour.add(groupLabour);
      _netWeightFields.add(netWeightField);
      _labourInKgFields.add(labourField);
    });

    if (widget.editItem != null) {
      if (widget.editItem!.polyWeight!.isNotEmpty) {
        getAllPolytheneData(widget.editItem!.polyWeight!);
      }

      if (widget.editItem!.labourInString!.isNotEmpty) {
        getAllLabourDataToEdit(widget.editItem!.labourInString!);
      }

      itemNameController.text = widget.editItem!.itemName.toString();
      itemWeightController.text = widget.editItem!.itemWeight.toString();
      itemRateController.text = widget.editItem!.itemRate.toString();
      labourControllerPerKg.text = widget.editItem!.labourPerKg == null
          ? ""
          : widget.editItem!.labourPerKg.toString();
      labourControllerPerPc.text = widget.editItem!.labourPerPc == null
          ? ""
          : widget.editItem!.labourPerPc.toString();

      if (widget.editItem!.noOfPc != null) {
        noOfPcController.text = widget.editItem!.noOfPc.toString();
        isNoOfPcIsVisible = true;
      }
    }

    
  }

  void _addTileOnPressedFunction() {
    if (_groupControllers.isNotEmpty) {
      if (_groupControllers[_groupControllers.length - 1]
              ._polyNoController
              .text
              .isNotEmpty &&
          _groupControllers[_groupControllers.length - 1]
              ._polyWtController
              .text
              .isNotEmpty) {
        isErrorVisible = false;
        final group = _GroupControllers();

        final nameField = _generateTextField(group._polyNoController);
        final telField = _generateTextField(group._polyWtController);

        setState(() {
          _groupControllers.add(group);
          _polyNoFields.add(nameField);
          _polyWtFields.add(telField);
        });
      } else {
        setState(() {
          isErrorVisible = true;
        });
      }
    } else {
      if (polyNumberControler.text.isNotEmpty &&
          polyWeightController.text.isNotEmpty) {
        isErrorVisible = false;
        final group = _GroupControllers();

        final nameField = _generateTextField(group._polyNoController);
        final telField = _generateTextField(group._polyWtController);

        setState(() {
          _groupControllers.add(group);
          _polyNoFields.add(nameField);
          _polyWtFields.add(telField);
        });
      } else {
        setState(() {
          isErrorVisible = true;
        });
      }
    }
  }

  void _addTilesForLabour() {
    if (_groupControllersLabour.isNotEmpty) {
      if (_groupControllersLabour[_groupControllersLabour.length - 1]
              ._netWeightController
              .text
              .isNotEmpty &&
          _groupControllersLabour[_groupControllersLabour.length - 1]
              ._labourInKgController
              .text
              .isNotEmpty) {
        isErrorVisibleForLabour = false;
        final groupLabour = _GroupControllersForLabour();

        final netWeightField = _generateTextFieldForLabour(
            groupLabour._netWeightController, "Net Weight");
        final labourField = _generateTextFieldForLabour(
            groupLabour._labourInKgController, "Labour (/kg)");

        setState(() {
          toggleSwitch.add(0);
          _groupControllersLabour.add(groupLabour);
          _netWeightFields.add(netWeightField);
          _labourInKgFields.add(labourField);
        });
      } else {
        setState(() {
          isErrorVisibleForLabour = true;
        });
      }
    } else {
      isErrorVisibleForLabour = false;
      final groupLabour = _GroupControllersForLabour();

      final netWeightField = _generateTextFieldForLabour(
          groupLabour._netWeightController, "Net Weight");
      final labourField = _generateTextFieldForLabour(
          groupLabour._labourInKgController, "Labour (/kg)");

      setState(() {
        toggleSwitch.add(0);
        _groupControllersLabour.add(groupLabour);
        _netWeightFields.add(netWeightField);
        _labourInKgFields.add(labourField);
      });
    }
  }

  Widget _addTile() {
    return IconButton(
        icon: const Icon(Icons.add_box_rounded),
        onPressed: _addTileOnPressedFunction);
  }

  Widget _addTileForLabour() {
    return IconButton(
        icon: const Icon(Icons.add_box_rounded), onPressed: _addTilesForLabour);
  }

  TextFormField _generateTextField(TextEditingController controller) {
    return TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(isDense: true),
        onChanged: (value) => {calculateNetWeight()});
  }

  TextFormField _generateTextFieldForLabour(
      TextEditingController controller, String labeltext) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
          labelText: labeltext,
          contentPadding: const EdgeInsets.all(5),
          border: const OutlineInputBorder()),
    );
  }

  void onToggleFunction(int index, int i) {
    if (index == 1) {
      final groupLabour = _GroupControllersForLabour();

      final netWeightField = _generateTextFieldForLabour(
          groupLabour._netWeightController, "No of Pc");
      final labourField = _generateTextFieldForLabour(
          groupLabour._labourInKgController, "Labour (/pc)");

      setState(() {
        toggleSwitch.removeAt(i);
        _groupControllersLabour.removeAt(i);
        _netWeightFields.removeAt(i);
        _labourInKgFields.removeAt(i);

        toggleSwitch.insert(i, index);
        _groupControllersLabour.add(groupLabour);
        _netWeightFields.insert(i, netWeightField);
        _labourInKgFields.insert(i, labourField);
      });
    } else {
      final groupLabour = _GroupControllersForLabour();

      final netWeightField = _generateTextFieldForLabour(
          groupLabour._netWeightController, "Net Weight");
      final labourField = _generateTextFieldForLabour(
          groupLabour._labourInKgController, "Labour (/kg)");

      setState(() {
        toggleSwitch.removeAt(i);
        _groupControllersLabour.removeAt(i);
        _netWeightFields.removeAt(i);
        _labourInKgFields.removeAt(i);

        toggleSwitch.insert(i, index);
        _groupControllersLabour.add(groupLabour);
        _netWeightFields.insert(i, netWeightField);
        _labourInKgFields.insert(i, labourField);
      });
    }
  }

  Widget _listView() {
    final children = [
      for (var i = 0; i < _groupControllers.length; i++)
        RichText(
          text: TextSpan(
            children: <InlineSpan>[
              const TextSpan(
                  text: "Poly No:  ",
                  style: TextStyle(fontSize: 16, color: Colors.black)),
              WidgetSpan(
                  child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 55),
                      child: IntrinsicWidth(child: _polyNoFields[i]))),
              const TextSpan(
                  text: "  Wt/poly (gm):  ",
                  style: TextStyle(fontSize: 16, color: Colors.black)),
              WidgetSpan(
                  child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 58),
                      child: IntrinsicWidth(child: _polyWtFields[i]))),
              WidgetSpan(
                  child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.delete,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _groupControllers.removeAt(i);
                    _polyNoFields.removeAt(i);
                    _polyWtFields.removeAt(i);
                  });
                },
              )),
            ],
          ),
        ),
    ];
    return SingleChildScrollView(
      child: Column(
        children: children,
      ),
    );
  }

  Widget _labourListView() {
    final children = [
      for (var i = 0; i < _groupControllersLabour.length; i++)
        Row(
          children: <Widget>[
            ToggleSwitch(
              minWidth: 50.0,
              minHeight: 20,
              activeBgColors: const [
                [Colors.blue],
                [Colors.green]
              ],
              activeFgColor: Colors.white,
              inactiveBgColor: const Color.fromARGB(255, 187, 186, 186),
              inactiveFgColor: Colors.white,
              initialLabelIndex: toggleSwitch[i],
              totalSwitches: 2,
              labels: const ['/Kg', '/Pc'],
              radiusStyle: true,
              onToggle: (index) {
                onToggleFunction(index!, i);
              },
            ),
            const SizedBox(width: 10),
            Expanded(child: _netWeightFields[i]),
            const SizedBox(width: 10),
            Expanded(child: _labourInKgFields[i]),
            Visibility(
              visible: i == 0 ? false : true,
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.delete,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _groupControllersLabour.removeAt(i);
                    _netWeightFields.removeAt(i);
                    _labourInKgFields.removeAt(i);
                  });
                },
              ),
            ),
            const SizedBox(height: 60)
          ],
        ),
    ];
    return SingleChildScrollView(
      child: Column(
        children: children,
      ),
    );
  }

  void fetchSimilarItem() {
    Provider.of<ItemChangeNotifier>(context, listen: false)
        .getAllItem()
        .then((value) {
      setState(() {
        isLoad = false;
        allItemData = value;
      });
    });
  }

  void calculateNetWeight() {
    double totalPolyWeight = 0;
    if (polyNumberControler.text.isNotEmpty &&
        polyWeightController.text.isNotEmpty &&
        polyWeightController.text != ".") {
      totalPolyWeight = double.parse(polyNumberControler.text) *
          double.parse(polyWeightController.text);
    }
    for (var i = 0; i < _groupControllers.length; i++) {
      if (_groupControllers[i]._polyNoController.text.isNotEmpty &&
          _groupControllers[i]._polyWtController.text.isNotEmpty) {
        totalPolyWeight +=
            double.parse(_groupControllers[i]._polyNoController.text) *
                double.parse(_groupControllers[i]._polyWtController.text);
      }
    }

    if (itemWeightController.text.isNotEmpty && toggleSwitch[0] != 1) {
      _groupControllersLabour[0]._netWeightController.text =
          (double.parse(itemWeightController.text).round() -
                  totalPolyWeight.round())
              .toString();
    }
  }

  TextEditingController itemNameController = TextEditingController();
  TextEditingController itemWeightController = TextEditingController();
  TextEditingController polyWeightController = TextEditingController();
  TextEditingController polyNumberControler = TextEditingController();
  TextEditingController itemRateController = TextEditingController();
  TextEditingController labourControllerPerKg = TextEditingController();
  TextEditingController labourControllerPerPc = TextEditingController();
  TextEditingController noOfPcController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool isLoad = false,
      isNoOfPcIsVisible = false,
      isErrorVisible = false,
      isErrorVisibleForLabour = false;
  List<ItemResultModel> allItemData = [];

  @override
  void dispose() {
    for (final controller in _groupControllers) {
      controller.dispose();
    }
    itemNameController.dispose();
    itemWeightController.dispose();
    polyWeightController.dispose();
    polyNumberControler.dispose();
    itemRateController.dispose();
    labourControllerPerKg.dispose();
    labourControllerPerPc.dispose();
    noOfPcController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Item Sell Form"),
          actions: <Widget>[
            Visibility(
              visible: widget.editItem == null ? true : false,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              ItemPurchaseForm(customer: widget.customer)));
                },
                child: const Text(
                  "Buy",
                  textScaleFactor: 1.4,
                  style: TextStyle(
                    color: Color.fromARGB(255, 173, 34, 24),
                  ),
                ),
              ),
            )
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
                    controller: itemNameController,
                    onChanged: (value) => {
                      itemRateController.text = "",
                      polyWeightController.text = "",
                      polyNumberControler.text = "",
                      labourControllerPerPc.text = "",
                      labourControllerPerKg.text = "",
                      setState(() {
                        isNoOfPcIsVisible == true
                            ? isNoOfPcIsVisible = false
                            : null;
                      })
                    },
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
                    itemNameController.text = suggestion.trim();

                    ItemResultModel selectedItemDetails =
                        allItemData.singleWhere((element) =>
                            element.itemName!.trim() == suggestion.trim());

                    itemRateController.text =
                        selectedItemDetails.wastage!.toString();

                    selectedItemDetails.polyWeight!.isNotEmpty
                        ? getAllPolytheneData(selectedItemDetails.polyWeight!)
                        : null;

                    if (selectedItemDetails.labourPerKg != null) {
                      toggleSwitch[0] = 0;
                      _groupControllersLabour[0]._labourInKgController.text =
                          selectedItemDetails.labourPerKg.toString();
                    }

                    if (selectedItemDetails.labourPerPc != null) {
                      onToggleFunction(1, 0);
                      _groupControllersLabour[0]._labourInKgController.text =
                          selectedItemDetails.labourPerPc.toString();
                    }

                    //  selectedItemDetails.labourPerKg == null
                    //      ? labourControllerPerKg.text = ""
                    //     : labourControllerPerKg.text =
                    //         selectedItemDetails.labourPerKg.toString();

                    // selectedItemDetails.labourPerPc == null
                    //     ? labourControllerPerPc.text = ""
                    //     : labourControllerPerPc.text =
                    //         selectedItemDetails.labourPerPc.toString();

                    setState(() {
                      selectedItemDetails.labourPerPc != null
                          ? isNoOfPcIsVisible = true
                          : null;
                    });
                  },
                  noItemsFoundBuilder: (context) {
                    return Container(
                      height: 0,
                    );
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                    controller: itemWeightController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                        labelText: "Weight (in gm)",
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
                    onChanged: (value) => {calculateNetWeight()}),
                const SizedBox(height: 20),
                RichText(
                  text: TextSpan(
                    children: <InlineSpan>[
                      const WidgetSpan(
                          child: Text("Poly No:  ",
                              style: TextStyle(fontSize: 16))),
                      WidgetSpan(
                          child: ConstrainedBox(
                              constraints: const BoxConstraints(minWidth: 60),
                              child: IntrinsicWidth(
                                child: TextFormField(
                                  controller: polyNumberControler,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  onChanged: (value) => {calculateNetWeight()},
                                  decoration:
                                      const InputDecoration(isDense: true),
                                  validator: (value) {
                                    if (polyWeightController.text.isNotEmpty &&
                                        value!.isEmpty) {
                                      return "Required or remove weight";
                                    }
                                    return null;
                                  },
                                ),
                              ))),
                      const WidgetSpan(
                          child: Text("  Wt/poly (gm):  ",
                              style: TextStyle(fontSize: 16))),
                      WidgetSpan(
                          child: ConstrainedBox(
                              constraints: const BoxConstraints(minWidth: 75),
                              child: IntrinsicWidth(
                                child: TextFormField(
                                    controller: polyWeightController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    decoration:
                                        const InputDecoration(isDense: true),
                                    validator: (value) {
                                      if (polyNumberControler.text.isNotEmpty &&
                                          value!.isEmpty) {
                                        return "Required or remove poly no";
                                      }
                                      return null;
                                    },
                                    onChanged: (value) =>
                                        {calculateNetWeight()}),
                              ))),
                    ],
                  ),
                ),
                Container(child: _listView()),
                Visibility(
                    visible: isErrorVisible,
                    child: const Text(
                      "please fill poly no and weight",
                      style: TextStyle(color: Colors.red),
                    )),
                _addTile(),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        controller: itemRateController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                            labelText: "Item Rate (in %)",
                            contentPadding: EdgeInsets.all(15),
                            border: OutlineInputBorder()),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Required";
                          }
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
                Container(child: _labourListView()),
                Visibility(
                    visible: isErrorVisibleForLabour,
                    child: const Text(
                      "please fill above labour fields",
                      style: TextStyle(color: Colors.red),
                    )),
                _addTileForLabour(),
                // Row(
                //   children: <Widget>[
                // ToggleSwitch(
                //   minWidth: 30.0,
                //   minHeight: 15,
                //   activeBgColors:const [
                //     [Colors.blue],
                //     [Colors.green]
                //   ],
                //   activeFgColor: Colors.white,
                //   inactiveBgColor:const Color.fromARGB(255, 187, 186, 186),
                //   inactiveFgColor: Colors.white,
                //   initialLabelIndex: 0,
                //   totalSwitches: 2,
                //   labels: const ['LabourInKg', 'LabourInPc'],
                //   radiusStyle: true,
                //   onToggle: (index) {

                //   },
                // ),
                // const SizedBox(width: 10,),
                //Container(child: _listView()),
                // Expanded(
                //   child: TextFormField(
                //     controller: labourControllerPerKg,
                //     onChanged: (value) => {
                //       setState(() {
                //         isNoOfPcIsVisible = false;
                //       }),
                //       labourControllerPerPc.text.isNotEmpty
                //           ? labourControllerPerPc.text = ""
                //           : null,
                //     },
                //     keyboardType: const TextInputType.numberWithOptions(
                //         decimal: true),
                //     decoration: const InputDecoration(
                //         labelText: "Labour (per kg)",
                //         contentPadding: EdgeInsets.all(15),
                //         border: OutlineInputBorder()),
                //   ),
                // ),
                // const SizedBox(width: 10),
                // Expanded(
                //   child: TextFormField(
                //     controller: labourControllerPerPc,
                //     onChanged: (value) => {
                //       setState(() {
                //         isNoOfPcIsVisible = true;
                //       }),
                //       labourControllerPerKg.text.isNotEmpty
                //           ? labourControllerPerKg.text = ""
                //           : null,
                //     },
                //     keyboardType: const TextInputType.numberWithOptions(
                //         decimal: true),
                //     decoration: const InputDecoration(
                //         labelText: "Labour (per Pc)",
                //         contentPadding: EdgeInsets.all(15),
                //         border: OutlineInputBorder()),
                //   ),
                // ),
                // ],
                //),
                //const SizedBox(height: 20),
                // Visibility(
                //   visible: isNoOfPcIsVisible,
                //   child: TextFormField(
                //     controller: noOfPcController,
                //     keyboardType:
                //         const TextInputType.numberWithOptions(decimal: true),
                //     decoration: const InputDecoration(
                //         labelText: "No of Piece",
                //         contentPadding: EdgeInsets.all(15),
                //         border: OutlineInputBorder()),
                //     validator: (value) {
                //       if (value!.isEmpty || int.parse(value) == 0) {
                //         return "Required";
                //       }
                //       return null;
                //     },
                //   ),
                // ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
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

                          //for total weight of poly
                          double totalPolyWeight = 0.0;
                          String polyWeightInString = "";
                          if (polyNumberControler.text.isNotEmpty &&
                              polyWeightController.text.isNotEmpty) {
                            totalPolyWeight =
                                double.parse(polyNumberControler.text) *
                                    double.parse(polyWeightController.text);

                            /********for poly in string**********/
                            polyWeightInString =
                                "${polyNumberControler.text}@${polyWeightController.text}, ";
                          }

                          for (var i = 0; i < _groupControllers.length; i++) {
                            if (_groupControllers[i]
                                    ._polyNoController
                                    .text
                                    .isNotEmpty &&
                                _groupControllers[i]
                                    ._polyWtController
                                    .text
                                    .isNotEmpty) {
                              totalPolyWeight += double.parse(
                                      _groupControllers[i]
                                          ._polyNoController
                                          .text) *
                                  double.parse(_groupControllers[i]
                                      ._polyWtController
                                      .text);
                              polyWeightInString +=
                                  "${_groupControllers[i]._polyNoController.text}@${_groupControllers[i]._polyWtController.text}, ";
                            }
                          } //end

                          int totalFineSilver =
                              ((double.parse(itemWeightController.text) -
                                          totalPolyWeight) *
                                      double.parse(
                                          itemRateController.text.toString()) /
                                      100)
                                  .round();

                          double labourNet = 0;
                          String labourInString = "";
                          for (int i = 0;
                              i < _groupControllersLabour.length;
                              i++) {
                            if (_groupControllersLabour[i]
                                    ._netWeightController
                                    .text
                                    .isNotEmpty &&
                                _groupControllersLabour[i]
                                    ._labourInKgController
                                    .text
                                    .isNotEmpty) {
                              if (toggleSwitch[i] == 1) {
                                labourNet += (double.parse(
                                        _groupControllersLabour[i]
                                            ._netWeightController
                                            .text) *
                                    double.parse(_groupControllersLabour[i]
                                        ._labourInKgController
                                        .text));
                                labourInString +=
                                    "${_groupControllersLabour[i]._netWeightController.text}@${_groupControllersLabour[i]._labourInKgController.text}/pc, ";
                              } else {
                                labourNet += (double.parse(
                                        _groupControllersLabour[i]
                                            ._netWeightController
                                            .text) *
                                    double.parse(_groupControllersLabour[i]
                                        ._labourInKgController
                                        .text) /
                                    1000);
                                labourInString +=
                                    "${_groupControllersLabour[i]._netWeightController.text}@${_groupControllersLabour[i]._labourInKgController.text}/kg, ";
                              }
                            }
                          }

                          // labourNet = (labourControllerPerKg.text.isEmpty &&
                          //         labourControllerPerPc.text.isNotEmpty
                          //     ? (double.parse(labourControllerPerPc.text) *
                          //             int.parse(noOfPcController.text))
                          //         .round()
                          //     : (labourControllerPerKg.text.isEmpty &&
                          //             labourControllerPerPc.text.isEmpty
                          //         ? 0
                          //         : ((double.parse(labourControllerPerKg.text) /
                          //                     1000) *
                          //                 (double.parse(
                          //                         itemWeightController.text) -
                          //                     totalPolyWeight))
                          //             .round()));

                          var invoice = InvoiceModel(
                              invoiceId: widget.editItem != null
                                  ? widget.editItem!.invoiceId
                                  : null,
                              customerId: widget.customer.customerId,
                              itemName:
                                  itemNameController.text.toUpperCase().trim(),
                              itemWeight:
                                  double.parse(itemWeightController.text),
                              itemRate: double.parse(
                                  itemRateController.text.toString()),
                              labourPerKg: labourControllerPerKg.text.isEmpty
                                  ? null
                                  : double.parse(labourControllerPerKg.text),
                              labourPerPc: labourControllerPerPc.text.isEmpty
                                  ? null
                                  : double.parse(labourControllerPerPc.text),
                              polyWeight: polyWeightInString.isEmpty
                                  ? polyWeightInString
                                  : polyWeightInString.substring(
                                      0, polyWeightInString.length - 2),
                              polyWeightinGm: totalPolyWeight,
                              noOfPc: noOfPcController.text.isEmpty
                                  ? null
                                  : int.parse(noOfPcController.text),
                              fineSilver: totalFineSilver,
                              labourNet: labourNet.round(),
                              labourInString: labourInString.isEmpty
                                  ? labourInString
                                  : labourInString.substring(
                                      0, labourInString.length - 2));

                          var item = ItemModel(
                              itemName:
                                  itemNameController.text.toUpperCase().trim(),
                              wastage: double.parse(
                                  itemRateController.text.toString()),
                              labourPerKg: _groupControllersLabour[0]
                                          ._labourInKgController
                                          .text
                                          .isNotEmpty &&
                                      toggleSwitch[0] == 0
                                  ? double.parse(_groupControllersLabour[0]
                                      ._labourInKgController
                                      .text)
                                  : null,
                              labourPerPc: _groupControllersLabour[0]
                                          ._labourInKgController
                                          .text
                                          .isNotEmpty &&
                                      toggleSwitch[0] == 1
                                  ? double.parse(_groupControllersLabour[0]
                                      ._labourInKgController
                                      .text)
                                  : null,
                              polyWeightinGm: polyWeightController.text.isEmpty
                                  ? null
                                  : double.parse(polyWeightController.text),
                              polyWeight: invoice.polyWeight);

                          widget.editItem != null
                              // ignore: use_build_context_synchronously
                              ? await Provider.of<InvoiceChangeNotifier>(
                                      context,
                                      listen: false)
                                  .add(invoice, item,
                                      invoiceId: widget.editItem!.invoiceId)
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
                                    content: Text("Item updated in invoice!"),
                                    duration: Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                    margin: EdgeInsets.all(20),
                                  ));
                                })
                              :
                              // ignore: use_build_context_synchronously
                              await Provider.of<InvoiceChangeNotifier>(context,
                                      listen: false)
                                  .add(invoice, item)
                                  .then((value) {
                                  setState(() {
                                    isLoad = false;
                                  });
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          ItemForm(
                                        customer: widget.customer,
                                      ),
                                    ),
                                  );
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content: Text("Item Added in invoice!"),
                                    duration: Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                    margin: EdgeInsets.all(20),
                                  ));
                                });
                        }
                      },
                      child: widget.editItem != null
                          ? const Text('Update Item',
                              style: TextStyle(color: Colors.white))
                          : const Text(
                              'Add Item',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () async {
                        if (widget.customer.customerId != null) {
                          await Printing.layoutPdf(
                              format: PdfPageFormat.roll80,
                              onLayout: (_) =>
                                  generateInvoice(widget.customer));
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
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
