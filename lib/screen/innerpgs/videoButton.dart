import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:memoriesweb/data/order_service_repo.dart';
import 'package:memoriesweb/data/transactions_service_repo.dart';
import 'package:memoriesweb/download/downloadCubit.dart';
import 'package:memoriesweb/download/downloadState.dart';
import 'package:memoriesweb/navigation/routes.dart';

class VideoOptionsSheet extends StatelessWidget {
  final String videoUrl;
  final int fordownload;

  VideoOptionsSheet({
    super.key,
    required this.videoUrl,
    required this.fordownload,
  });

  final TransServiceRepo trans = TransServiceRepo();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VideoDownloadCubit(OrderServiceRepo()),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocConsumer<VideoDownloadCubit, VideoDownloadState>(
          listener: (context, state) {
            if (state is VideoDownloadFinished) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Center(child: Text("Download finished.")),
                ),
              );

              showDialog(
                context: context,
                builder: (context) {
                  double selectedRating = 0;

                  return StatefulBuilder(
                    builder: (context, setState) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: const Text(
                          "Rate Our Editor",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text("How would you rate your experience?"),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                double starIndex = index + 1;
                                return IconButton(
                                  icon: Icon(
                                    starIndex <= selectedRating
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                    size: 32,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      selectedRating = starIndex;
                                    });
                                  },
                                );
                              }),
                            ),
                          ],
                        ),
                        actions: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Complaint Started"),
                                    ),
                                  );

                                  final replacedRoute = RoutesEnum
                                      .videoComplaint
                                      .path
                                      .replaceFirst(':complaint', 'true');
                                  print('Navigating to complaint page...');
                                  print('Route: $replacedRoute');

                                  context.push(
                                    replacedRoute,
                                    extra: (String path, String fileName) {
                                      trans.updateOrder(
                                        targetUrl: videoUrl,
                                        path: path,
                                        fileName: fileName,
                                      );
                                    },
                                  );
                                },
                                child: const Text("Complaint"),
                              ),

                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Cancel"),
                              ),

                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "You rated: $selectedRating stars",
                                      ),
                                    ),
                                  );

                                  trans.updateOrder(
                                    targetUrl: videoUrl,
                                    newRating: selectedRating,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    75,
                                    228,
                                    55,
                                  ),
                                ),
                                child: const Text("Submit"),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            } else if (state is VideoDownloadError) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Center(child: Text("Download failed.")),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is VideoDownloading) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.0),
                    child: LinearProgressIndicator(value: state.progress / 100),
                  ),
                  const SizedBox(height: 8),
                  Text(state.status, style: const TextStyle(fontSize: 12)),
                ],
              );
            } else if (state is VideoDownloadFinished) {
              return Text(
                'File downloaded to: ${state.path}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.green),
              );
            } else {
              return ElevatedButton.icon(
                icon: const Icon(Icons.download),
                label: const Text("Download Video"),
                onPressed: () {
                  context.read<VideoDownloadCubit>().startDownload(
                    videoUrl,
                    fordownload,
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
