import 'package:flutter/material.dart';
import 'package:time_tracker_flutter_course/app/home/models/job.dart';

class JobListTile extends StatelessWidget {
  const JobListTile({Key key, this.job, this.onTap}) : super(key: key);
  final Job job;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(job.name, style: TextStyle(color: Colors.white),),
      trailing: Icon(Icons.chevron_right, color: Colors.white70,),
      onTap: onTap,
    );
  }
}
