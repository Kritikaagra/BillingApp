class ItemResultModel {
  int? itemId;
  String? itemName, polyWeight;
  double? polyWeightinGm, wastage, labourPerKg, labourPerPc;

  ItemResultModel({
    this.itemId,
    this.itemName,
    this.polyWeight,
    this.polyWeightinGm,
    this.wastage,
    this.labourPerKg,
    this.labourPerPc,
  });

  factory ItemResultModel.fromJson(Map<String, dynamic> json) => ItemResultModel(
      itemId: json["itemId"],
      itemName: json["itemName"],
      polyWeight: json["polyWeight"],
      polyWeightinGm: json["polyWeightinGm"]?.toDouble(),
      wastage: json["wastage"]?.toDouble(),
      labourPerKg: json["labourPerKg"]?.toDouble(),
      labourPerPc: json["labourPerPc"]?.toDouble()
      );

  Map<String, dynamic> toJson() => {
        "itemId": itemId,
        "itemName": itemName,
        "polyWeight": polyWeight,
        "polyWeightinGm": polyWeightinGm,
        "wastage": wastage,
        "labourPerKg": labourPerKg,
        "labourPerPc": labourPerPc,
      };

  copyWith(
      {
      int? itemId,
      String? itemName,
      String? polyWeight,
      double? polyWeightinGm,
      double? wastage,
      double? labourPerkg,
      double? labourPerPc}) {
    return ItemResultModel(
        itemId: itemId ?? this.itemId,
        polyWeight: polyWeight ?? this.polyWeight,
        itemName: itemName ?? this.itemName,
        polyWeightinGm: polyWeightinGm ?? this.polyWeightinGm,
        wastage: wastage ?? this.wastage,
        labourPerKg: labourPerKg ?? labourPerKg,
        labourPerPc: labourPerPc ?? this.labourPerPc);
  }
}
