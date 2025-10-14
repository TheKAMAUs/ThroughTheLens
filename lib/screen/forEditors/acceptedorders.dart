import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:memoriesweb/data/auth_service.dart';
import 'package:memoriesweb/data/order_service_repo.dart';
import 'package:memoriesweb/data/transactions_service_repo.dart';
import 'package:memoriesweb/model/ordermodel.dart';
import 'package:memoriesweb/navigation/routes.dart';
import 'package:memoriesweb/screen/innerpgs/fullScreenImagePage.dart';
import 'package:memoriesweb/screen/innerpgs/smallVideo.dart';

class AcceptedOrdersPage extends StatefulWidget {
  const AcceptedOrdersPage({Key? key}) : super(key: key);

  @override
  State<AcceptedOrdersPage> createState() => _AcceptedOrdersPageState();
}

class _AcceptedOrdersPageState extends State<AcceptedOrdersPage> {
  late Future<List<OrderModel>> _acceptedOrdersFuture;
  final OrderServiceRepo orders = OrderServiceRepo();
  final TransServiceRepo trans = TransServiceRepo();

  final TextEditingController titleController = TextEditingController();
  // final TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _acceptedOrdersFuture = orders.getOrderByAssignedEditorId(
      globalUserDoc!.userId,
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    // descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accepted Orders')),
      body: FutureBuilder<List<OrderModel>>(
        future: _acceptedOrdersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final orders = snapshot.data;

          if (orders == null) {
            return const Center(child: Text('No accepted orders.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          (order.title != null && order.title!.isNotEmpty)
                              ? '-Title: ${order.title}'
                              : '-Title: add the best caption',
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
                              '-Description: ${order.description ?? 'add the best description'}',
                              style: TextStyle(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onSurface, // dynamic color
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              (order.status != null && order.status!.isNotEmpty)
                                  ? '-Status: ${order.status}'
                                  : '-Status: pending',
                            ),
                            const SizedBox(height: 8),
                            if (order.complaint ==
                                true) // only show if complaint is true
                              Row(
                                children: [
                                  Text(
                                    '- Complaint',
                                    style: TextStyle(fontSize: 16),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.only(left: 6.0),
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        isThreeLine: true,
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
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (_) => FullScreenImagePage(
                                                    imageUrl: img,
                                                    fordownload: 1,
                                                  ),
                                            ),
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

                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Submit Edited Video"),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      controller: titleController,
                                      decoration: const InputDecoration(
                                        labelText: 'Title',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    // TextField(
                                    //   controller: descriptionController,
                                    //   decoration: const InputDecoration(
                                    //     labelText: 'Description',
                                    //     border: OutlineInputBorder(),
                                    //   ),
                                    //   maxLines: 3,
                                    // ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context), // cancel
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(
                                        context,
                                      ); // close the dialog
                                      order.copyWith(
                                        title: titleController.text.trim(),
                                        // description:
                                        //     descriptionController.text.trim(),
                                      );
                                      // Now push the route with callback
                                      final replacedRoute = Routes.videoEdited
                                          .replaceFirst(':edited', 'true');

                                      print('Navigating to Editor page...');
                                      print('Route: $replacedRoute');
                                      context.push(
                                        replacedRoute,
                                        extra: (String path, String fileName) {
                                          print('🎯 onDone was called!');
                                          trans.editedOrder(
                                            order: order,
                                            path: path,
                                            fileName: fileName,
                                          );
                                        },
                                      );
                                    },
                                    child: const Text('Submit'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors
                                              .greenAccent, // Button background color
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: const Text('Submit the Edited Version'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            243,
                            121,
                            55,
                          ), // Button background color
                        ),
                      ),
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
