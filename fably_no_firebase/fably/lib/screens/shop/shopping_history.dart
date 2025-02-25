import 'package:flutter/material.dart';

class ShoppingHistoryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> orders = [
    {
      'id': 'ORD12345',
      'date': 'Feb 20, 2025',
      'total': '\$120.50',
      'status': 'Delivered',
    },
    {
      'id': 'ORD12346',
      'date': 'Feb 18, 2025',
      'total': '\$85.75',
      'status': 'Shipped',
    },
    {
      'id': 'ORD12347',
      'date': 'Feb 15, 2025',
      'total': '\$45.00',
      'status': 'Cancelled',
    },
  ];

  const ShoppingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shopping History",
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text("Order: ${order['id']}",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Date: ${order['date']}"),
                  Text("Total: ${order['total']}"),
                  Text("Status: ${order['status']}",
                      style: TextStyle(
                          color: order['status'] == 'Delivered'
                              ? Colors.green
                              : order['status'] == 'Shipped'
                                  ? Colors.orange
                                  : Colors.red)),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          );
        },
      ),
    );
  }
}
