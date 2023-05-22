class InvoiceModel {
  int? invoiceId, customerId, noOfPc;
  String? itemName, polyWeight;
  double? itemWeight, polyWeightinGm, itemRate, labourPerKg, labourPerPc;
  int? fineSilver, labourNet;

  InvoiceModel({
    this.invoiceId,
    this.customerId,
    this.itemName,
    this.polyWeight,
    this.itemWeight,
    this.polyWeightinGm,
    this.itemRate,
    this.labourPerKg,
    this.labourPerPc,
    this.noOfPc,
    this.fineSilver,
    this.labourNet,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) => InvoiceModel(
      invoiceId: json["invoiceId"],
      customerId: json["customerId"],
      itemName: json["itemName"],
      polyWeight: json["polyWeight"],
      itemWeight: json["itemWeight"]?.toDouble(),
      polyWeightinGm: json["polyWeightinGm"]?.toDouble(),
      itemRate: json["itemRate"]?.toDouble(),
      labourPerKg: json["labourPerKg"]?.toDouble(),
      labourPerPc: json["labourPerPc"]?.toDouble(),
      noOfPc: json["noOfPc"],
      fineSilver: json["fineSilver"],
      labourNet: json["labourNet"]);

  Map<String, dynamic> toJson() => {
        "invoiceId": invoiceId,
        "customerId": customerId,
        "itemName": itemName,
        "polyWeight": polyWeight,
        "itemWeight": itemWeight,
        "polyWeightinGm": polyWeightinGm,
        "itemRate": itemRate,
        "labourPerKg": labourPerKg,
        "labourPerPc": labourPerPc,
        "noOfPc": noOfPc,
        "fineSilver": fineSilver,
        "labourNet": labourNet
      };

  copyWith(
      {int? invoiceId,
      int? customerId,
      String? itemName,
      String? polyWeight,
      double? itemWeight,
      double? polyWeightinGm,
      double? itemRate,
      double? labourPerkg,
      double? labourPerPc,
      int? noOfPc,
      int? fineSilver,
      int? labourNet}) {
    return InvoiceModel(
        invoiceId: invoiceId ?? this.invoiceId,
        customerId: customerId ?? this.customerId,
        itemName: itemName ?? this.itemName,
        polyWeight: polyWeight ?? this.polyWeight,
        itemWeight: itemWeight ?? this.itemWeight,
        polyWeightinGm: polyWeightinGm ?? this.polyWeightinGm,
        itemRate: itemRate ?? this.itemRate,
        labourPerKg: labourPerKg ?? labourPerKg,
        labourPerPc: labourPerPc ?? this.labourPerPc,
        noOfPc: noOfPc ?? this.noOfPc,
        fineSilver: fineSilver ?? this.fineSilver,
        labourNet: labourNet ?? this.labourNet);
  }
}
