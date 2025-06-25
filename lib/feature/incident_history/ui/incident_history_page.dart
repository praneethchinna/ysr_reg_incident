import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';
import 'package:ysr_reg_incident/app_colors/app_colors.dart';
import 'package:ysr_reg_incident/feature/incident_history/model/incident_details_model.dart';
import 'package:ysr_reg_incident/feature/incident_history/model/incident_history_model.dart';
import 'package:ysr_reg_incident/feature/incident_history/provider/incident_history_provider.dart';
import 'package:ysr_reg_incident/feature/incident_history/widgets/show_files.dart';
import 'package:ysr_reg_incident/feature/incident_registration/ui/incident_home_page.dart';
import 'package:ysr_reg_incident/feature/incident_registration/widgets/build_information_row.dart';
import 'package:ysr_reg_incident/feature/incident_registration/widgets/reg_text_widget.dart';

class IncidentHistoryPage extends ConsumerWidget {
  const IncidentHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incidentHistoryAsync = ref.watch(incidentHistoryProvider);

    return WillPopScope(
      onWillPop: () async {
        if (ref.watch(tabIndexProvider) != 0) {
          ref.read(tabIndexProvider.notifier).update((state) => 0);
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: null,
        body: incidentHistoryAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error: ${error.toString()}'),
          ),
          data: (incidents) {
            if (incidents.isEmpty) {
              return const Center(child: Text('No incidents found'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: incidents.length,
              itemBuilder: (context, index) {
                return _IncidentCard(incident: incidents[index]);
              },
            );
          },
        ),
      ),
    );
  }
}

class _IncidentCard extends ConsumerStatefulWidget {
  final IncidentHistoryModel incident;

  const _IncidentCard({required this.incident});

  @override
  ConsumerState<_IncidentCard> createState() => _IncidentCardState();
}

class _IncidentCardState extends ConsumerState<_IncidentCard>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'declined':
        return Colors.redAccent;
      case 'recorded':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _toggleExpand() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  Widget _buildIncidentHistoryStepper(int incidentId) {
    final incidentHistoryStatusAsync =
        ref.watch(incidentHistoryStatusProvider(incidentId));

    return incidentHistoryStatusAsync.when(
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (history) {
        final reversedHistory = history.reversed.toList();

        return Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Stepper(
            type: StepperType.vertical,
            currentStep: 0,
            controlsBuilder: (context, details) => const SizedBox.shrink(),
            steps: List.generate(
              reversedHistory.length,
              (index) {
                final historyItem = reversedHistory[index];

                return Step(
                  title: Text(
                    historyItem.status,
                    style: const TextStyle(fontSize: 12),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('dd MMM yyyy, h:mm a')
                            .format(DateTime.parse(historyItem.updatedAt)),
                        style:
                            const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                      const SizedBox(height: 5),
                      Text(historyItem.remarks ?? ''),
                    ],
                  ),
                  content: const SizedBox.shrink(),
                  state: StepState.values.firstWhere(
                    (state) {
                      switch (historyItem.status.toLowerCase()) {
                        case 'open':
                          return state == StepState.indexed;
                        case 'pending':
                          return state == StepState.editing;
                        case 'declined':
                          return state == StepState.error;
                        case 'recorded':
                          return state == StepState.complete;
                        default:
                          return false;
                      }
                    },
                  ),
                  isActive: true,
                );
              },
            ),
            stepIconBuilder: (index, step) {
              Color color;
              IconData iconData;

              switch (step) {
                case StepState.indexed:
                  color = Colors.blue;
                  iconData = Icons.help_outline;
                  break;
                case StepState.editing:
                  color = Colors.orange;
                  iconData = Icons.access_time;
                  break;
                case StepState.error:
                  color = Colors.redAccent;
                  iconData = Icons.close;
                  break;
                case StepState.complete:
                  color = Colors.green;
                  iconData = Icons.check;
                  break;
                default:
                  color = Colors.grey;
                  iconData = Icons.help_outline;
              }

              return CircleAvatar(
                backgroundColor: color,
                radius: 12,
                child: Icon(
                  iconData,
                  size: 14,
                  color: Colors.white,
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0.2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section (always visible)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('dd MMMM, yyyy')
                          .format(DateTime.parse(widget.incident.createdAt)),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(widget.incident.status),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _getStatusColor(widget.incident.status),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        widget.incident.status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(8),
                Text(
                  widget.incident.incidentType,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Expandable content
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildExpandedContent(),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),

          // Expand/collapse button
          GestureDetector(
            onTap: _toggleExpand,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(),
              child: Row(
                children: [
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 24,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent() {
    if (!isExpanded) return const SizedBox.shrink();

    return ref.watch(incidentDetailsProvider(widget.incident.incidentId)).when(
          loading: () => const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Error: $error',
              style: const TextStyle(color: Colors.red),
            ),
          ),
          data: (details) {
            final incidentDetails = details.incidentDetails;
            return Column(
              children: [
                // Tabs
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.grey.shade400, width: 1),
                  ),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.black87,
                    indicator: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                    tabs: const [
                      Tab(text: 'Incident Information'),
                      Tab(text: 'Incident Updates'),
                    ],
                  ),
                ),

                // Tab content
                SizedBox(
                  height: 400, // Adjust height as needed
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Incident Information Tab
                      SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RegTextWidget(text: "Personal Information"),
                            Gap(8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.grey.shade300, width: 1),
                              ),
                              child: Column(
                                children: [
                                  buildInformationRow(
                                      title: 'Name',
                                      value: incidentDetails.name),
                                  buildInformationRow(
                                      title: 'Gender',
                                      value: incidentDetails.gender),
                                  buildInformationRow(
                                      title: 'Phone Number',
                                      value: incidentDetails.mobile),
                                  buildInformationRow(
                                      title: 'Email ID',
                                      value: incidentDetails.email ?? 'N/A'),
                                  buildInformationRow(
                                      title: 'Parliament',
                                      value: incidentDetails.parliament),
                                  buildInformationRow(
                                      title: 'Assembly',
                                      value: incidentDetails.assembly),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            RegTextWidget(text: "Incident Information"),
                            Gap(8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.grey.shade300, width: 1),
                              ),
                              child: Column(
                                children: [
                                  buildInformationRow(
                                      title: 'Incident Type',
                                      value: incidentDetails.incidentType),
                                  buildInformationRow(
                                      title: 'Incident Location',
                                      value: incidentDetails.incidentPlace),
                                  buildInformationRow(
                                      title: 'Incident Date',
                                      value: incidentDetails.incidentDate),
                                  buildInformationRow(
                                      title: 'Incident Time',
                                      value: incidentDetails.incidentTime),
                                  buildInformationRow(
                                      title: 'Description',
                                      value:
                                          incidentDetails.incidentDescription),
                                  ref
                                      .watch(incidentProofFilesProvider(
                                          incidentDetails.incidentId))
                                      .when(
                                          data: (urls) {
                                            if (urls.isNotEmpty) {
                                              return Column(
                                                children: [
                                                  _buildFileSection(
                                                      'Incident Proofs', urls),
                                                ],
                                              );
                                            }
                                            return const SizedBox.shrink();
                                          },
                                          loading: () => Container(),
                                          error: (error, _) =>
                                              Text('Error: $error')),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),

                      // Incident Updates Tab
                      _buildIncidentHistoryStepper(
                          details.incidentDetails.incidentId),
                    ],
                  ),
                ),
              ],
            );
          },
        );
  }

  Widget _buildFileSection(String title, List<String> multiUrls) {
    List<String> urls = multiUrls
        .map((url) =>
            "https://peddapuramysrcp.com/api/view-incident-media/proof/${url.split("/").last}")
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: urls.length > 3 ? 3 : urls.length,
            itemBuilder: (context, index) {
              final url = urls[index];
              final isVideo = _isVideo(url);
              final isAudio = _isAudio(url);

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () => showFullDialog(context, url),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: isVideo
                        ? Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey[300],
                            child: Image.asset(
                              'assets/video_icon.png',
                              width: 40,
                              height: 40,
                            ),
                          )
                        : isAudio
                            ? Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey[300],
                                child: Icon(
                                  Icons.audio_file,
                                  color: Colors.purple,
                                  size: 60,
                                ),
                              )
                            : Image.network(
                                url,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 100,
                                    height: 100,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.broken_image,
                                        color: Colors.grey),
                                  );
                                },
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  );
                                },
                              ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // void _showDialog(BuildContext context, String url) {
  //   final isVideo = _isVideo(url);
  //   final isAudio = _isAudio(url);
  //
  //   showDialog(
  //     context: context,
  //     builder: (_) {
  //       return AlertDialog(
  //         contentPadding: const EdgeInsets.all(8),
  //         content: SizedBox(
  //           width: 300,
  //           height: 300,
  //           child: isVideo
  //               ? Chewie(
  //                   controller: ChewieController(
  //                       videoPlayerController:
  //                           VideoPlayerController.network(url),
  //                       autoPlay: true,
  //                       looping: false,
  //                       allowFullScreen: true,fullScreenByDefault: true,
  //                       deviceOrientationsAfterFullScreen: [
  //                         DeviceOrientation.portraitUp,
  //                         DeviceOrientation.portraitDown,
  //                       ],
  //                       deviceOrientationsOnEnterFullScreen: [
  //                         DeviceOrientation.landscapeLeft,
  //                         DeviceOrientation.landscapeRight,
  //                       ]),
  //                 )
  //               : isAudio
  //                   ? _buildAudioPlayer(url)
  //                   : InstaImageViewer(
  //                       child: Image.network(
  //                         url,
  //                         height: 150,
  //                         width: double.infinity,
  //                         fit: BoxFit.contain,
  //                         loadingBuilder: (context, child, loadingProgress) {
  //                           if (loadingProgress == null) return child;
  //                           return SizedBox(
  //                             height: 150,
  //                             child: Center(
  //                               child: CircularProgressIndicator.adaptive(
  //                                 value: loadingProgress.expectedTotalBytes !=
  //                                         null
  //                                     ? loadingProgress.cumulativeBytesLoaded /
  //                                         loadingProgress.expectedTotalBytes!
  //                                     : null,
  //                               ),
  //                             ),
  //                           );
  //                         },
  //                       ),
  //                     ),
  //         ),
  //       );
  //     },
  //   );
  // }

  bool _isVideo(String url) =>
      url.endsWith('.mp4') ||
      url.endsWith('.avi') ||
      url.endsWith('.mov') ||
      url.endsWith('.mkv');

  bool _isAudio(String url) =>
      url.endsWith('.mp3') || url.endsWith('.wav') || url.endsWith('.ogg');
}
