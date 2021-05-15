import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:time_tracker_flutter_course/app/home/models/job.dart';
import 'package:time_tracker_flutter_course/common_widgets/show_alert_dialog.dart';
import 'package:time_tracker_flutter_course/common_widgets/show_exception_error.dart';
import 'package:time_tracker_flutter_course/services/databases.dart';

class EditJobPage extends StatefulWidget {
  const EditJobPage({Key key, @required this.database, this.job})
      : super(key: key);
  final Database database;
  final Job job;

  static Future<void> show(BuildContext context,
      {Database database, Job job}) async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => EditJobPage(
              database: database,
              job: job,
            ),
        fullscreenDialog: true));
  }

  @override
  _EditJobPageState createState() => _EditJobPageState();
}

class _EditJobPageState extends State<EditJobPage> {
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _ratePerHourFocusNode = FocusNode();

  final _formKey = GlobalKey<FormState>();
  String _name;
  int _ratePerHour;

  bool _isLoading = false;

  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  @override
  void initState() {
    if (widget.job != null) {
      _name = widget.job.name;
      _ratePerHour = widget.job.ratePerHour;
    }
    super.initState();
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _ratePerHourFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
    });
    if (_validateAndSave()) {
      // await Future.delayed(Duration(seconds: 3));
      try {
        final jobs = await widget.database.jobsStream().first;
        final allNames = jobs.map((job) => job.name).toList();
        if (widget.job != null) {
          allNames.remove(widget.job.name);
        }
        if (allNames.contains(_name)) {
          showAlertDialog(context,
              title: 'Job already exists',
              content: 'Please add an unique job name',
              actionText: 'OK');
        } else {
          final id = widget.job?.id ?? documentId();
          final job = Job(name: _name, ratePerHour: _ratePerHour, id: id);
          await widget.database.setJob(job);
          Navigator.of(context).pop();
        }
      } on FirebaseException catch (e) {
        showExceptionError(context, title: 'Operation Failed.', exception: e);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _nameEditingComplete() {
    FocusScope.of(context).requestFocus(_ratePerHourFocusNode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 5,
        title: Center(child: Text(widget.job == null ? 'Add Job' : 'Edit Job')),
        backgroundColor: Colors.blueAccent,
        actions: <Widget>[
          FlatButton(
              onPressed: _submit,
              child: Text(
                'Save',
                style: TextStyle(fontSize: 18),
              ))
        ],
      ),
      body: _buildContents(),
      backgroundColor: Colors.blueGrey,
    );
  }

  Widget _buildContents() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading == true
            ? Center(child: CircularProgressIndicator())
            : Card(
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: _buildForm(),
                ),
              ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _buildFormContents(),
        ));
  }

  List<Widget> _buildFormContents() {
    return [
      TextFormField(
        focusNode: _nameFocusNode,
        decoration: InputDecoration(labelText: 'Job Name'),
        initialValue: _name,
        validator: (value) => value.isNotEmpty ? null : 'Name can\'t be empty',
        onSaved: (value) => _name = value,
        onEditingComplete: _nameEditingComplete,
      ),
      TextFormField(
        focusNode: _ratePerHourFocusNode,
        decoration: InputDecoration(labelText: 'Rate per Hour'),
        initialValue: _ratePerHour != null ? '$_ratePerHour' : null,
        keyboardType: TextInputType.numberWithOptions(
          signed: false,
          decimal: false,
        ),
        onSaved: (value) => _ratePerHour = int.tryParse(value) ?? 0,
        onEditingComplete: _submit,
      ),
      // Center(child: CircularProgressIndicator()),
    ];
  }
}
