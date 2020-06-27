import './AddCompOff.dart';
import 'package:flutter/material.dart';
import './lists.dart';
import 'package:intl/intl.dart';

void main() => runApp(CompOffs());

class CompOffs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "CompOffs",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.cyan,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

var val = 0.0;

class _MyHomePageState extends State<MyHomePage> {
  final DbManager dbManager = new DbManager();

  List<ListsCompOff> listCompOffs;

  _MyHomePageState() {
    dbManager.getTotal().then((value) => setState(() {
          val = value;
        }));
  }
  final autho = ['-1', '-0.5', '0.5', '1'];
  final comment = TextEditingController();
  String leaves;
  DateTime datechoosen;
  void addCompOffs(BuildContext ctx) {
    showModalBottomSheet(
        context: ctx,
        builder: (bctx) {
          return AddCompOff(
            dbManager: dbManager,
            val: val,
            submitCompOff: submitCompOff,
            comment: comment,
          );
        });
  }

  void submitCompOff(comment, leaves, datechoosen) {
    if (comment.text.isEmpty) {
      return;
    }

    ListsCompOff lcompoff = new ListsCompOff(
      comment: comment.text,
      leaves: leaves,
      dt: datechoosen.toString(),
    );
    setState(() {
      dbManager.insertDB(lcompoff).then((id) => {
            comment.clear(),
          });
      val = val + double.parse(leaves);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ClipPath(
              clipper: BezierClipper(),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.3,
                color: Color.fromRGBO(116, 245, 231, 1),
                width: double.infinity,
                child: Center(
                  child: val > -0.5
                      ? Text(
                          "You got ${val.toString()} leaves left",
                          style: TextStyle(
                            fontSize: 24,
                            fontFamily: 'Calibri',
                          ),
                        )
                      : Text("Your leaves can't be negative",
                          style: TextStyle(color: Colors.red, fontSize: 24)),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              width: double.infinity,
              //List of Leaves
              height: MediaQuery.of(context).size.height * 0.65,
              child: FutureBuilder(
                future: dbManager.getData(),
                builder: (ctx, snapshot) {
                  if (snapshot.hasData) {
                    listCompOffs = snapshot.data;
                    return ListView.builder(
                      itemBuilder: (ctx, index) {
                        return Card(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.black, width: 1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          color: Color.fromRGBO(231, 250, 246, 1),
                          child: Row(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(
                                  right: 20,
                                  bottom: 5,
                                  left: 10,
                                  top: 5,
                                ),
                                padding: EdgeInsets.all(10),
                                child:
                                    double.parse(listCompOffs[index].leaves) < 0
                                        ? Text(
                                            (double.parse(listCompOffs[index]
                                                        .leaves) *
                                                    -1)
                                                .toStringAsFixed(1),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          )
                                        : Text(
                                            double.parse(
                                                    listCompOffs[index].leaves)
                                                .toStringAsFixed(1),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                decoration: BoxDecoration(
                                  color:
                                      double.parse(listCompOffs[index].leaves) <
                                              0
                                          ? Colors.red
                                          : Colors.green,
                                  border: Border.all(
                                    width: 2,
                                    color: double.parse(
                                                listCompOffs[index].leaves) <
                                            0
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      listCompOffs[index].comment,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                      ),
                                    ),
                                    Text(
                                      DateFormat.yMMMd().format(DateTime.parse(
                                          listCompOffs[index].dt)),
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                padding: EdgeInsets.all(20),
                                color: Colors.black,
                                alignment: Alignment.bottomLeft,
                                onPressed: () {
                                  dbManager.deleteComp(listCompOffs[index].id);
                                  val = val -
                                      double.parse(listCompOffs[index].leaves);
                                  setState(() {
                                    listCompOffs.removeAt(index);
                                  });
                                },
                                icon: Icon(Icons.do_not_disturb_on),
                              ),
                            ],
                          ),
                        );
                      },
                      itemCount: listCompOffs.length,
                    );
                  }
                  return Text('');
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Take CompOff",
        foregroundColor: Colors.black,
        backgroundColor: Color.fromRGBO(116, 245, 231, 1),
        onPressed: () {
          setState(() {
            addCompOffs(context);
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class BezierClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = new Path();
    path.lineTo(0, size.height * 0.85); //vertical line
    path.cubicTo(size.width / 3, size.height + 70, 2 * size.width / 3,
        size.height * 0.5, size.width, size.height * 0.7); //cubic curve
    path.lineTo(size.width, 0); //vertical line
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
