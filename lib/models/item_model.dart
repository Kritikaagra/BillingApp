class ItemModel {
  String? itemName, polyWeight;
  double? polyWeightinGm, wastage, labourPerKg, labourPerPc;

  ItemModel({
    this.itemName,
    this.polyWeight,
    this.polyWeightinGm,
    this.wastage,
    this.labourPerKg,
    this.labourPerPc,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) => ItemModel(
      itemName: json["itemName"],
      polyWeight: json["polyWeight"],
      polyWeightinGm: json["polyWeightinGm"],
      wastage: json["wastage"],
      labourPerKg: json["labourPerKg"],
      labourPerPc: json["labourPerPc"]);

  Map<String, dynamic> toJson() => {
        "itemName": itemName,
        "polyWeight" : polyWeight,
        "polyWeightinGm": polyWeightinGm,
        "wastage": wastage,
        "labourPerKg": labourPerKg,
        "labourPerPc": labourPerPc,
      };

  copyWith(
      {
      String? itemName,
      String? polyWeight,
      double? polyWeightinGm,
      double? wastage,
      double? labourPerkg,
      double? labourPerPc}) {
    return ItemModel(
        itemName: itemName ?? this.itemName,
        polyWeight: polyWeight ?? this.polyWeight,
        polyWeightinGm: polyWeightinGm ?? this.polyWeightinGm,
        wastage: wastage ?? this.wastage,
        labourPerKg: labourPerKg ?? labourPerKg,
        labourPerPc: labourPerPc ?? this.labourPerPc);
  }
}
