import 'package:flutter/foundation.dart'; //@required is included in foundation can include material.dart too
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path/path.dart';

class DbManager {
  Database _database;

  Future opendb() async {
    if (_database == null) {
      _database = await openDatabase(
          join(await getDatabasesPath(), 'CompOff.db'),
          version: 1, onCreate: (Database db, int version) async {
        await db.execute(
            "CREATE TABLE compoff(id INTEGER PRIMARY KEY,comment TEXT,leaves TEXT,dt TEXT)");
      });
    }
  }

  Future<int> insertDB(ListsCompOff listcomoff) async {
    await opendb();
    return await _database.insert('compoff', listcomoff.toMap());
  }

  Future<List<ListsCompOff>> getData() async {
    await opendb();
    final List<Map<String, dynamic>> maps = await _database.query('compoff',orderBy: "dt DESC");
    return List.generate(maps.length, (idx) {
      return ListsCompOff(
        id: maps[idx]['id'],
        leaves: maps[idx]['leaves'],
        comment: maps[idx]['comment'],
        dt: maps[idx]['dt'],
      );
    });
  }

  Future<void> deleteComp(int id) async{
    await opendb();
    await _database.delete('compoff',where: 'id=?',whereArgs: [id]);
  }

  Future<double> getTotal() async{
    await opendb();
    final List<Map<String,dynamic>> total= await _database.rawQuery('Select leaves from compoff');
    if(total.isEmpty)
    {
      return 0;
    }
    else
    {
      double t=0;
      for(int i=0;i<total.length;i++)
      {
        t+=double.parse(total[i]['leaves']);
      }
      return t;
    }
  }
}

class ListsCompOff {
  int id; //'final' to be run time constant
  String comment;
  String leaves;
  String dt;

  ListsCompOff({
    this.id,
    @required this.comment,
    @required this.leaves,
    @required this.dt,
  }); //curly braces to kmake it named arguments

  Map<String, dynamic> toMap() {
    return {'comment': comment, 'leaves': leaves, 'dt': dt};
  }
}
