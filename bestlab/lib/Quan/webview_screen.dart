// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// class WebViewScreen extends StatefulWidget {
//   final String url;

//   WebViewScreen({required this.url});

//   @override
//   _WebViewScreenState createState() => _WebViewScreenState();
// }

// class _WebViewScreenState extends State<WebViewScreen> {
//   late WebViewController _controller;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Device Statistics'),
//       ),
//       body: WebView(
//         initialUrl: widget.url,
//         javascriptMode: JavascriptMode.unrestricted,
//         onWebViewCreated: (WebViewController webViewController) {
//           _controller = webViewController;
//         },
//         onPageStarted: (String url) {
//           print('Page started loading: $url');
//         },
//         onPageFinished: (String url) {
//           print('Page finished loading: $url');
//         },
//         onWebResourceError: (error) {
//           print('Error loading page: ${error.description}');
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:intl/intl.dart';

class WebViewScreen extends StatefulWidget {
  final String url;

  WebViewScreen({required this.url});

  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late WebViewController _controller;
  String originalUrl;
  String selectedTab = 'Time Range';
  DateTime? fromTime;
  DateTime? toTime;
  Duration? liveDataInterval;

  _WebViewScreenState() : originalUrl = '';

  @override
  void initState() {
    super.initState();
    originalUrl = widget.url;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Device Statistics'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _showEditDialog(context),
          ),
        ],
      ),
      body: WebView(
        initialUrl: originalUrl,
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _controller = webViewController;
        },
        onPageStarted: (String url) {
          print('Page started loading: $url');
        },
        onPageFinished: (String url) {
          print('Page finished loading: $url');
        },
        onWebResourceError: (error) {
          print('Error loading page: ${error.description}');
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit Time Settings'),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8, // Adjust width
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Wrap(
                      spacing: 8.0, // Add spacing between the chips
                      children: [
                        ChoiceChip(
                          label: Text('Time Range'),
                          selected: selectedTab == 'Time Range',
                          onSelected: (selected) {
                            setState(() {
                              selectedTab = 'Time Range';
                            });
                          },
                        ),
                        ChoiceChip(
                          label: Text('Live Data'),
                          selected: selectedTab == 'Live Data',
                          onSelected: (selected) {
                            setState(() {
                              selectedTab = 'Live Data';
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    if (selectedTab == 'Time Range')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Time'),
                        SizedBox(height: 8),
                        _buildTimePicker(
                          context,
                          'From',
                          fromTime,
                              (newTime) => setState(() => fromTime = newTime),
                        ),
                        SizedBox(height: 8),
                        _buildTimePicker(
                          context,
                          'To',
                          toTime,
                              (newTime) => setState(() => toTime = newTime),
                        ),
                      ],
                    )
                  else if (selectedTab == 'Live Data')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Interval'),
                        SizedBox(height: 8),
                        _buildLiveDataIntervalPicker(
                          context,
                          liveDataInterval,
                              (newInterval) => setState(() => liveDataInterval = newInterval),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    _applyChanges();
                    Navigator.of(context).pop();
                  },
                  child: Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTimePicker(BuildContext context, String label, DateTime? initialTime, ValueChanged<DateTime> onTimeSelected) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('$label: ${initialTime != null ? DateFormat('dd/MM/yyyy HH:mm').format(initialTime) : 'Not set'}'),
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: initialTime ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );
            if (pickedDate != null) {
              TimeOfDay? pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(initialTime ?? DateTime.now()),
              );
              if (pickedTime != null) {
                onTimeSelected(DateTime(
                  pickedDate.year,
                  pickedDate.month,
                  pickedDate.day,
                  pickedTime.hour,
                  pickedTime.minute,
                ));
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildLiveDataIntervalPicker(BuildContext context, Duration? initialInterval, ValueChanged<Duration> onIntervalSelected) {
    String intervalText = initialInterval != null
        ? '${initialInterval.inHours.toString().padLeft(2, '0')}:${(initialInterval.inMinutes % 60).toString().padLeft(2, '0')}'
        : 'Not set';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Interval: $intervalText'),
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: () async {
            TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay(
                hour: initialInterval?.inHours ?? 0,
                minute: initialInterval?.inMinutes.remainder(60) ?? 0,
              ),
            );
            if (pickedTime != null) {
              onIntervalSelected(Duration(hours: pickedTime.hour, minutes: pickedTime.minute));
            }
          },
        ),
      ],
    );
  }

  void _applyChanges() {
    String newUrl = originalUrl; // Start with the original URL

    if (selectedTab == 'Time Range' && fromTime != null && toTime != null) {
      int fromEpoch = fromTime!.millisecondsSinceEpoch;  // Use milliseconds directly
      int toEpoch = toTime!.millisecondsSinceEpoch;      // Use milliseconds directly
      newUrl += "&from=$fromEpoch&to=$toEpoch";
    } else if (selectedTab == 'Live Data' && liveDataInterval != null) {
      int minutes = liveDataInterval!.inMinutes;
      newUrl += "&from=now-${minutes}m&to=now";
    }

    print('Loading new URL: $newUrl'); // Debugging line
    _controller.loadUrl(newUrl);
  }
}
