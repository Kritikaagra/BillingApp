class ItemPurchaseModel {
  int? receivableId;
  int? customerId;
  String? itemName;
  double? itemWeight, itemRate, labourPerKg, labourPerPc;
  int? noOfPc, fineSilver, labourNet;

  ItemPurchaseModel({
    this.receivableId,
    this.customerId,
    this.itemName,
    this.itemRate,
    this.itemWeight,
    this.fineSilver,
    this.labourPerKg,
    this.labourPerPc,
    this.noOfPc,
    this.labourNet
  });

  factory ItemPurchaseModel.fromJson(Map<String, dynamic> json) => ItemPurchaseModel(
      receivableId: json["receivableId"],
      customerId: json["customerId"],
      itemName: json["itemName"],
      itemWeight: json["itemWeight"]?.toDouble(),
      itemRate: json["itemRate"]?.toDouble(),
      fineSilver: json["fineSilver"],
      labourPerKg: json["labourPerKg"]?.toDouble(),
      labourPerPc: json["labourPerPc"]?.toDouble(),
      noOfPc: json["noOfPc"],
      labourNet: json["labourNet"]
  );

  Map<String, dynamic> toJson() => {
        "receivableId" : receivableId,
        "customerId" : customerId,
        "itemName": itemName,
        "itemWeight": itemWeight,
        "itemRate": itemRate,
        "fineSilver": fineSilver,
        "labourPerKg": labourPerKg,
        "labourPerPc": labourPerPc,
        "noOfPc" : noOfPc,
        "labourNet" : labourNet
      };

  copyWith(
      {
      int? receivableId,
       int? customerId,
      String? itemName,
      double? itemWeight,
      double? itemRate,
      double? labourPerKg,
      double? labourPerPc,
      int? fineSilver,
      int? noOfPc,
      int?labourNet
      }) {
    return ItemPurchaseModel(
      receivableId: receivableId ?? this.receivableId,
        customerId: customerId?? this.customerId,
        itemName: itemName ?? this.itemName,
        itemWeight: itemWeight ?? this.itemWeight,
        itemRate: itemRate ?? this.itemRate,
        fineSilver: fineSilver ?? this.fineSilver,
        labourPerKg: labourPerKg ?? this.labourPerKg,
        labourPerPc: labourPerPc ?? this.labourPerPc,
        noOfPc: noOfPc ?? this.noOfPc,
        labourNet: labourNet ?? this.labourNet
    );
  }
}
