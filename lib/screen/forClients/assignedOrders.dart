import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memoriesweb/data/order_service_repo.dart';
import 'package:memoriesweb/model/ordermodel.dart';
import 'package:memoriesweb/navigation/routes.dart';
import 'package:memoriesweb/screen/innerpgs/smallVideo.dart';

class AssignedOrdersPage extends StatefulWidget {
  const AssignedOrdersPage({Key? key}) : super(key: key);

  @override
  State<AssignedOrdersPage> createState() => _AssignedOrdersPageState();
}

class _AssignedOrdersPageState extends State<AssignedOrdersPage> {
  final OrderServiceRepo orders = OrderServiceRepo();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assigned Orders')),
      body: FutureBuilder<List<OrderModel>>(
        future: orders.fetchOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return const Center(child: Text('No accepted orders.'));
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return
              // ListTile(
              //   title: Text(order.title ?? 'No Title'),
              //   subtitle: Text("Order ID: ${order.orderId}"),
              // );
              Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title:
                        //  Text(
                        //   '-${order.title != null ? order.title : 'best caption will be added'}',
                        // ),
                        Text(
                          (order.title != null && order.title!.isNotEmpty)
                              ? '-Title: ${order.title}'
                              : '-Title: best caption will be added',
                        ),

                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${order.orderedAt?.year}-${order.orderedAt?.month}-${order.orderedAt?.day} • Source: ${order.amount}',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 4),

                            Text(
                              (order.description != null &&
                                      order.description!.isNotEmpty)
                                  ? '-Description: ${order.description}'
                                  : '-Description: Not Added',

                              style: const TextStyle(
                                color: Color.fromARGB(221, 239, 237, 237),
                              ),
                            ),

                            const SizedBox(height: 4),
                            Text(
                              (order.status != null && order.status!.isNotEmpty)
                                  ? '-Status: ${order.status}'
                                  : '-Status: pending',
                            ),
                          ],
                        ),
                        // isThreeLine: true,
                      ),
                      if (order.imageUrls.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 150,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children:
                                  order.imageUrls.map((img) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        right: 8.0,
                                      ),
                                      child: GestureDetector(
                                        onTap: () {
                                          context.push(
                                            Routes.nestedExPFullScreenImage,
                                            extra: {
                                              'url': img,
                                              'fordownload': 0,
                                            },
                                          );
                                          print(
                                            '📤 Navigating to video page with URL: ${img}',
                                          );
                                        },
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: FadeInImage(
                                            placeholder: AssetImage(
                                              'assets/user_icon.png',
                                            ), // Placeholder image
                                            image: NetworkImage(img),
                                            fit: BoxFit.cover,
                                            // Set a default placeholder in case the image fails to load
                                            imageErrorBuilder: (
                                              context,
                                              error,
                                              stackTrace,
                                            ) {
                                              return Image.asset(
                                                'assets/user_icon.png', // Fallback image
                                                fit: BoxFit.cover,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ),
                        ),
                      ],

                      if (order.videoUrls!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 150,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children:
                                  order.videoUrls!.map((vid) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        right: 8.0,
                                      ),

                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: SmallVideo(
                                          fromProfile: false,
                                          url: vid,
                                          fordownload: 5,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      // ElevatedButton(
                      //   onPressed: () {
                      //     showOrderAcceptanceDialog(
                      //       context,

                      //       order: order, // optional
                      //     );
                      //   },
                      //   child: const Text('Accept'),
                      // ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
