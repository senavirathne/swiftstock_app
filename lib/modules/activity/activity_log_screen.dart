// modules/activity/activity_log_screen.dart

import 'package:flutter/material.dart';
import 'activity_model.dart';
import 'activity_service.dart';

class ActivityLogScreen extends StatefulWidget {
  const ActivityLogScreen({Key? key}) : super(key: key);

  @override
  _ActivityLogScreenState createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  List<Activity> _activities = [];
  final ActivityService _activityService = ActivityService();

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  void _loadActivities() async {
    List<Activity> activities = await _activityService.getAllActivities();
    setState(() {
      _activities = activities;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_activities.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Activity Log'),
        ),
        body: const Center(child: Text('No activities to show')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Log'),
      ),
      body: ListView.builder(
        itemCount: _activities.length,
        itemBuilder: (context, index) {
          final activity = _activities[index];
          return ListTile(
            title: Text(activity.description),
            subtitle: Text(activity.dateTime.toLocal().toString()),
          );
        },
      ),
    );
  }
}
