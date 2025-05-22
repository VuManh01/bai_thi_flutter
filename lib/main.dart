import 'package:flutter/material.dart';
import 'db.dart';
import 'order_model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Order Management',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: OrderPage(),
    );
  }
}

class OrderPage extends StatefulWidget {
  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final itemController = TextEditingController();
  final itemNameController = TextEditingController();
  final quantityController = TextEditingController();
  final priceController = TextEditingController();
  final currencyController = TextEditingController();
  final searchController = TextEditingController();

  List<Order> orders = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders({String? keyword}) async {
    final result = await OrderDatabase.instance.getAllOrders(keyword: keyword);
    setState(() => orders = result);
  }

  Future<void> _addOrder() async {
    if (itemController.text.isEmpty ||
        itemNameController.text.isEmpty ||
        priceController.text.isEmpty ||
        quantityController.text.isEmpty ||
        currencyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
      );
      return;
    }

    final order = Order(
      item: itemController.text,
      itemName: itemNameController.text,
      quantity: int.tryParse(quantityController.text) ?? 1,
      price: double.tryParse(priceController.text) ?? 0.0,
      currency: currencyController.text,
    );

    await OrderDatabase.instance.insertOrder(order);
    _clearFields();
    await _loadOrders();
  }

  void _editOrder(Order order) {
    itemController.text = order.item;
    itemNameController.text = order.itemName;
    quantityController.text = order.quantity.toString();
    priceController.text = order.price.toString();
    currencyController.text = order.currency;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Chỉnh sửa đơn hàng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: itemController, decoration: InputDecoration(labelText: 'Item')),
            TextField(controller: itemNameController, decoration: InputDecoration(labelText: 'Item Name')),
            TextField(controller: quantityController, decoration: InputDecoration(labelText: 'Quantity')),
            TextField(controller: priceController, decoration: InputDecoration(labelText: 'Price')),
            TextField(controller: currencyController, decoration: InputDecoration(labelText: 'Currency')),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Hủy'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: Text('Lưu'),
            onPressed: () async {
              final updated = Order(
                id: order.id,
                item: itemController.text,
                itemName: itemNameController.text,
                quantity: int.tryParse(quantityController.text) ?? 1,
                price: double.tryParse(priceController.text) ?? 0.0,
                currency: currencyController.text,
              );

              await OrderDatabase.instance.updateOrder(updated);
              Navigator.of(context).pop();
              _clearFields();
              await _loadOrders();
            },
          ),
        ],
      ),
    );
  }



  void _clearFields() {
    itemController.clear();
    itemNameController.clear();
    quantityController.clear();
    priceController.clear();
    currencyController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Order')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Input Grid
            Row(
              children: [
                Expanded(child: TextField(controller: itemController, decoration: InputDecoration(labelText: 'Item'))),
                SizedBox(width: 8),
                Expanded(child: TextField(controller: itemNameController, decoration: InputDecoration(labelText: 'Item Name'))),
              ],
            ),
            Row(
              children: [
                Expanded(child: TextField(controller: quantityController, decoration: InputDecoration(labelText: 'Quantity'))),
                SizedBox(width: 8),
                Expanded(child: TextField(controller: priceController, decoration: InputDecoration(labelText: 'Price'))),
                SizedBox(width: 8),
                Expanded(child: TextField(controller: currencyController, decoration: InputDecoration(labelText: 'Currency'))),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _addOrder,
                child: Text('Add Item to Cart'),
              ),
            ),
            Divider(),
            TextField(
              controller: searchController,
              decoration: InputDecoration(labelText: 'Search by Item or Item Name'),
              onChanged: (value) => _loadOrders(keyword: value),
            ),
            SizedBox(height: 10),
            Expanded(
              child: orders.isEmpty
                  ? Center(child: Text("No orders found"))
                  : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Item')),
                    DataColumn(label: Text('Item Name')),
                    DataColumn(label: Text('Quantity')),
                    DataColumn(label: Text('Price')),
                    DataColumn(label: Text('Currency')),
                    DataColumn(label: Text('Action')),
                  ],
                  rows: orders.map((order) {
                    return DataRow(cells: [
                      DataCell(Text(order.item)),
                      DataCell(Text(order.itemName)),
                      DataCell(Text(order.quantity.toString())),
                      DataCell(Text(order.price.toString())),
                      DataCell(Text(order.currency)),
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              _editOrder(order);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await OrderDatabase.instance.deleteOrder(order.id!);
                              await _loadOrders();
                            },
                          ),
                        ],
                      )),
                    ]);

                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 16),

            Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 20),
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                )
                ,child: Center(
                child: Text(
                    'So 8, Ton That Thuyet, Cau Giay, Ha Noi',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }