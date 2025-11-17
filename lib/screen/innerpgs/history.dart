import 'package:flutter/material.dart';
import 'package:memoriesweb/data/order_service_repo.dart';
import 'package:memoriesweb/model/ordermodel.dart';
import 'package:memoriesweb/responsive/constrained_scaffold.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  bool _isLoading = true;
  List<OrderModel> _orders = [];
  String? _error;
  final OrderServiceRepo order = OrderServiceRepo();

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      final orders = await order.fetchOrdersfor_HISTORY();

      final now = DateTime.now();

      // ✅ Keep only orders older than 2 hours
      final oldOrders =
          orders.where((o) {
            final orderTime = o.orderedAt;
            if (orderTime == null) return false;

            final differenceInMinutes = now.difference(orderTime).inMinutes;
            print('⏰ Order ${o.orderId} is $differenceInMinutes minutes old');

            return differenceInMinutes >= 120; // ✅ older than 2 hours
          }).toList();

      setState(() {
        _orders = oldOrders;
        _isLoading = false;
      });

      print('✅ Loaded ${_orders.length} old orders');
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      print('❌ Error loading orders: $e');
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case "paid":
        return Colors.green;
      case "failed":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedScaffold(
      appBar: AppBar(
        title: const Text("Edit History"),
        backgroundColor: const Color.fromARGB(255, 199, 202, 204),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
            tooltip: "Reload",
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Text(
                  "❌ Error loading history:\n$_error",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              )
              : _orders.isEmpty
              ? const Center(
                child: Text(
                  "No history found 📭",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _orders.length,
                itemBuilder: (context, index) {
                  final order = _orders[index];

                  return Card(
                    elevation: 1.5,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      title: Row(
                        children: [
                          Flexible(
                            child: Text(
                              order.title ?? "No Title",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (order.complaint == true) ...[
                            const SizedBox(width: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: const [
                                  Icon(
                                    Icons.circle,
                                    size: 8,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Complaint',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),

                      subtitle: Text(
                        "Order ID: ${order.orderId ?? 'N/A'}",
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 10,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            order.paymentStatus,
                          ).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          order.paymentStatus?.toUpperCase() ?? "PENDING",
                          style: TextStyle(
                            color: _getStatusColor(order.paymentStatus),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      onTap: () {
                        // Navigate to order details if needed
                      },
                    ),
                  );
                },
              ),
    );
  }
}
