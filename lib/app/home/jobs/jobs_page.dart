import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker_flutter_course/app/home/job_entries/job_entries_page.dart';
import 'package:time_tracker_flutter_course/app/home/jobs/edit_job_page.dart';
import 'package:time_tracker_flutter_course/app/home/jobs/empty_content.dart';
import 'package:time_tracker_flutter_course/app/home/jobs/job_list_tile.dart';
import 'package:time_tracker_flutter_course/app/home/jobs/list_items_builder.dart';
import 'package:time_tracker_flutter_course/app/home/models/job.dart';
import 'package:time_tracker_flutter_course/common_widgets/show_exception_error.dart';
import 'package:time_tracker_flutter_course/services/databases.dart';

class JobsPage extends StatelessWidget {
  Future<void> _delete(BuildContext context, Job job) async {
    try {
      final database = Provider.of<Database>(context, listen: false);
      await database.deleteJob(job);
    } on FirebaseException catch (e) {
      showExceptionError(
        context,
        title: 'Operation Failed.',
        exception: e,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Jobs',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
        ),
        backgroundColor: Colors.orange,
      ),
      body: _buildContents(context),
      backgroundColor: Colors.blueGrey,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => EditJobPage.show(
          context,
          database: Provider.of<Database>(context, listen: false),
        ),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  Widget _buildContents(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    return StreamBuilder<List<Job>>(
      stream: database.jobsStream(),
      builder: (context, snapshot) {
        return ListItemsBuilder<Job>(
          snapshot: snapshot,
          itemBuilder: (context, job) => Dismissible(
            key: Key('job-${job.id}'),
            background: Container(
              color: Colors.red,
              child: Icon(Icons.delete_outline, size: 28),
              alignment: Alignment.centerRight,
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) => _delete(context, job),
            child: JobListTile(
              job: job,
              onTap: () => JobEntriesPage.show(context, job),
            ),
          ),
        );

        if (snapshot.hasData) {
          final jobs = snapshot.data;
          if (jobs.isNotEmpty) {
            final children = jobs
                .map((job) => JobListTile(
                      job: job,
                      onTap: () => EditJobPage.show(context, job: job),
                    ))
                .toList();
            return ListView(children: children);
          } else {
            return EmptyContent();
          }
        }
        if (snapshot.hasError) {
          return Center(child: Text('Has some error!'));
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
