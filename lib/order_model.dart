class Order {
  final int? id;
  final String item;
  final String itemName;
  final double price;
  final String currency;
  final int quantity;

  Order({
    this.id,
    required this.item,
    required this.itemName,
    required this.price,
    required this.currency,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'item': item,
      'itemName': itemName,
      'price': price,
      'currency': currency,
      'quantity': quantity,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      item: map['item'],
      itemName: map['itemName'],
      price: map['price'],
      currency: map['currency'],
      quantity: map['quantity'],
    );
  }
}
