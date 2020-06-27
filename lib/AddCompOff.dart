import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import './lists.dart';

class AddCompOff extends StatefulWidget {
  final val;
  final Function submitCompOff;
  final DbManager dbManager;
  final comment;

  AddCompOff({
    this.val,
    this.dbManager,
    this.submitCompOff,
    this.comment,
  });
  @override
  _AddCompOffState createState() => _AddCompOffState();
}

class _AddCompOffState extends State<AddCompOff> {
  final comment = TextEditingController();
  DateTime selectedDate = DateTime.now();
  void presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2019),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) {
        selectedDate = DateTime.now();
      } else {
        setState(() {
          selectedDate = pickedDate;
        });
      }
    });
  }

  String dropdownValue = 'Full Day CompOff';
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Card(
              shape: ContinuousRectangleBorder(
                side: BorderSide(
                  color: Color.fromRGBO(116, 245, 231, 1),
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                padding: EdgeInsets.only(left: 10,right: 10),
                child: DropdownButton<String>(
                  autofocus: false,
                  icon: Icon(Icons.arrow_downward),
                  iconEnabledColor: Color.fromRGBO(116, 245, 231, 1),
                  isExpanded: true,
                  value: dropdownValue,
                  onChanged: (String newValue) {
                    setState(() {
                      dropdownValue = newValue;
                    });
                  },
                  items: <String>[
                    'Full Day CompOff',
                    'Half Day CompOff',
                    'Half Day Leave',
                    'Full Day Leave',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Card(
              shape: ContinuousRectangleBorder(
                side: BorderSide(color: Color.fromRGBO(116, 245, 231, 1), width: 3),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                padding: EdgeInsets.only(left: 10,right: 10),
                child: TextField(
                  autofocus: false,
                  maxLines: 1,
                  controller: comment,
                  decoration: InputDecoration(
                    hintText: "Reason",
                    hintStyle: TextStyle(color: Colors.black),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Card(
              shape: ContinuousRectangleBorder(
                side: BorderSide(
                  color: Color.fromRGBO(116, 245, 231, 1),
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                padding: EdgeInsets.only(left: 10,right: 10),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        DateFormat.yMd().format(selectedDate),
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    IconButton(
                      autofocus: false,
                      icon: Icon(Icons.date_range),
                      color: Color.fromRGBO(116, 245, 231, 1),
                      onPressed: presentDatePicker,
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            
            IconButton(
              icon: Icon(Icons.arrow_forward),
              iconSize: 50,
              color: Color.fromRGBO(116, 245, 231, 1),
              onPressed: () {
                widget.dbManager.getTotal().then((value) {
                  if (dropdownValue == 'Full Day CompOff') {
                    dropdownValue = '1';
                  } else if (dropdownValue == 'Half Day CompOff') {
                    dropdownValue = '0.5';
                  } else if (dropdownValue == 'Half Day Leave') {
                    dropdownValue = '-0.5';
                  } else if (dropdownValue == 'Full Day Leave') {
                    dropdownValue = '-1';
                  }
                  if ((value + double.parse(dropdownValue)) > -0.5) {
                    widget.submitCompOff(comment, dropdownValue, selectedDate);
                  }
                  dropdownValue = 'Full Day CompOff';
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
