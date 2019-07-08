import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:piggy_bank/services/authentication.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:piggy_bank/models/value.dart';
import 'dart:async';
import 'dart:math' as math;

class HomePage extends StatefulWidget {
  double _countSubjectValue;

  HomePage({Key key, this.auth, this.userId, this.onSignedOut})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String userId;

  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Value> _valueList;

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final _textEditingController = TextEditingController();
  StreamSubscription<Event> _onValueAddedSubscription;
  StreamSubscription<Event> _onValueChangedSubscription;

  Query _valueQuery;

  bool _isEmailVerified = false;

  @override
  void initState() {
    super.initState();

    _checkEmailVerification();

    _valueList = new List();
    _valueQuery = _database
        .reference()
        .child("value")
        .orderByChild("userId")
        .equalTo(widget.userId);
    _onValueAddedSubscription = _valueQuery.onChildAdded.listen(_onEntryAdded);
    _onValueChangedSubscription =
        _valueQuery.onChildChanged.listen(_onEntryChanged);
  }

  void _checkEmailVerification() async {
    _isEmailVerified = await widget.auth.isEmailVerified();
    if (!_isEmailVerified) {
      _showVerifyEmailDialog();
    }
  }

  void _resentVerifyEmail() {
    widget.auth.sendEmailVerification();
    _showVerifyEmailSentDialog();
  }

  void _showVerifyEmailDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Verify your account"),
          content: new Text("Please verify account in the link sent to email"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Resent link"),
              onPressed: () {
                Navigator.of(context).pop();
                _resentVerifyEmail();
              },
            ),
            new FlatButton(
              child: new Text("Dismiss"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showVerifyEmailSentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Verify your account"),
          content:
              new Text("Link to verify account has been sent to your email"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Dismiss"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _onValueAddedSubscription.cancel();
    _onValueChangedSubscription.cancel();
    super.dispose();
  }

  _onEntryChanged(Event event) {
    var oldEntry = _valueList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      _valueList[_valueList.indexOf(oldEntry)] =
          Value.fromSnapshot(event.snapshot);
    });
  }

  _onEntryAdded(Event event) {
    setState(() {
      _valueList.add(Value.fromSnapshot(event.snapshot));
    });
  }

  _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  _addNewValue(double valueItem) {
    if (valueItem != 0) {
      Value value = new Value(valueItem, widget.userId, false);
      _database.reference().child("value").push().set(value.toJson());
    }
  }

  _updateOrAddValue(Value value, double valueItem, bool add) {
    if (add) {
      _addNewValue(valueItem);
    } else {
      if (value != null) {
        if (valueItem != 0) {
          value.subject = valueItem;
          _database
              .reference()
              .child("value")
              .child(value.key)
              .set(value.toJson());
        }
      }
    }
  }

  _updateValueCompleted(Value value) {
    //Toggle completed
    value.completed = !value.completed;
    _updateOrAddValue(value, 0, false);
  }

  _deleteValue(String valueId, int index) {
    _database.reference().child("value").child(valueId).remove().then((_) {
      print("Delete $valueId successful");
      setState(() {
        _valueList.removeAt(index);
      });
    });
  }

  _showDialog(BuildContext context, int index) async {
    _textEditingController.clear();
    bool _add = true;
    Value _value = null;
    if (index >= 0) {
      _textEditingController.text = _valueList[index].subject.toString();
      _add = false;
      _value = _valueList[index];
    }
    await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: new Row(children: <Widget>[
              new Expanded(
                child: TextField(
                  controller: _textEditingController,
                  autofocus: true,
                  decoration: InputDecoration(labelText: 'Add new value'),
                  keyboardType: TextInputType.numberWithOptions(
                      decimal: true, signed: true),
                ),
              ),
            ]),
            actions: <Widget>[
              new FlatButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              new FlatButton(
                child: const Text('Save'),
                onPressed: () {
                  _updateOrAddValue(
                      _value, double.parse(_textEditingController.text), _add);
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  Widget _itemBuilderChooser(BuildContext context, int index) {
    if (_valueList.length < index + 1) {
      return _itemBuilderWeek(context, index);
    } else {
      return _itemBuilder(context, index);
    }
  }

  Widget _itemBuilder(BuildContext context, int index) {
    String valueId = _valueList[index].key;
    double subject = _valueList[index].subject;
    String moneyArt = _valueList[index].moneyArt;
    String date = _valueList[index].formattedDate;
    bool completed = _valueList[index].completed;
    String userId = _valueList[index].userId;
    widget._countSubjectValue += subject;
    var color = Colors.black;
    if (subject < 0) {
      color = Colors.red;
    }
    return Dismissible(
      key: Key(valueId),
      background: Container(color: Colors.red),
      onDismissed: (direction) async {
        _deleteValue(valueId, index);
      },
      child: Card(
        child: ListTile(
          title: Text(
            '$date: $subject $moneyArt',
            style: TextStyle(fontSize: 20.0, color: color),
          ),
          trailing: IconButton(
              icon: (completed)
                  ? Icon(
                      Icons.done_outline,
                      color: Colors.green,
                      size: 20.0,
                    )
                  : Icon(Icons.done, color: Colors.grey, size: 20.0),
              onPressed: () {
                _updateValueCompleted(_valueList[index]);
              }),
          onTap: () {
            _showDialog(context, index);
          },
        ),
      ),
    );
  }

  Widget _itemBuilderWeek(BuildContext context, int index) {
    var color = Colors.green;
    if (widget._countSubjectValue < 0) {
      color = Colors.red;
    }
    return Card(
      child: ListTile(
          title: Text(
        'Week summery: ${widget._countSubjectValue}',
        style: TextStyle(fontSize: 20.0, color: color),
      )),
    );
  }

  Widget _showValueList() {
    if (_valueList.length > 0) {
      widget._countSubjectValue = 0;
      return ListView.builder(
          shrinkWrap: true,
          itemCount: _valueList.length + 1,
          itemBuilder: _itemBuilderChooser
          );
    } else {
      return Center(
          child: Text(
        "Welcome. Your list is empty",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 30.0),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Piggy Bank'),
        actions: <Widget>[
          new FlatButton(
              child: new Text('Logout',
                  style: new TextStyle(fontSize: 17.0, color: Colors.white)),
              onPressed: _signOut)
        ],
      ),
      body: _showValueList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showDialog(context, -1);
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: Container(
        alignment: Alignment.center,
        color: Colors.blue,
        width: 20,
        height: 30,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('Week summery'),
            Text(widget._countSubjectValue.toString()),
          ],
        ),
      ),
    );
  }
}

class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({this.decimalRange})
      : assert(decimalRange == null || decimalRange > 0);

  final int decimalRange;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, // unused.
    TextEditingValue newValue,
  ) {
    TextSelection newSelection = newValue.selection;
    String truncated = newValue.text;

    if (decimalRange != null) {
      String value = newValue.text;

      if (value.contains(".") &&
          value.substring(value.indexOf(".") + 1).length > decimalRange) {
        truncated = oldValue.text;
        newSelection = oldValue.selection;
      } else if (value == ".") {
        truncated = "0.";

        newSelection = newValue.selection.copyWith(
          baseOffset: math.min(truncated.length, truncated.length + 1),
          extentOffset: math.min(truncated.length, truncated.length + 1),
        );
      }

      return TextEditingValue(
        text: truncated,
        selection: newSelection,
        composing: TextRange.empty,
      );
    }
    return newValue;
  }
}
