class CustomerModel {
  int? customerId;
  double? silverRate;
  String? customerName, purchaseDate;

  CustomerModel({
    this.customerId,
    this.customerName,
    this.silverRate,
    this.purchaseDate,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel(
        customerId: json["customerId"],
        customerName: json["customerName"],
        silverRate: json["silverRate"]?.toDouble(),
        purchaseDate: json["purchaseDate"],
      );

  Map<String, dynamic> toJson() => {
        "customerId": customerId,
        "customerName": customerName,
        "silverRate": silverRate,
        "purchaseDate": purchaseDate,
      };

  copyWith({
    int? customerId,
    String? customerName,
    double? silverRate,
    String? purchaseDate,
  }) {
    return CustomerModel(
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      silverRate: silverRate ?? this.silverRate,
      purchaseDate: purchaseDate ?? this.purchaseDate,
    );
  }
}
