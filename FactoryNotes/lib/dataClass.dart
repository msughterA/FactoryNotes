import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';
//import 'package:path_provider/path_provider.dart';
import 'dart:async';

const String fileId='fileId';
const String date='date';
const String name='name';
const String checked='checked';
const String id='id';
const String batchName='batchName';

class blockTabledata{
  int id;
  int serialNumber;
  int blocklength;
  int BlocksLength;
  String title;
  String fieldtype;
  String fieldvalue;
  String fileId;
  String checked;
  blockTabledata({this.title,this.checked,
    this.fieldtype,this.fieldvalue,this.fileId,this.id,this.serialNumber,this.blocklength,this.BlocksLength});
  Map<String ,dynamic> toMap (){
    var map=<String ,dynamic>{
      'id':id,
      'fileId':fileId,
      'title':title,
      'fieldtype':fieldtype,
      'fieldvalue':fieldvalue,
      'checked':checked,
      'serialNumber':serialNumber,
      'blocklength':blocklength,
      'BlocksLength':BlocksLength,
    };
    return map;
  }
  blockTabledata.fromMap(Map<String,dynamic> map){
    id=map['id'];
    title=map['title'];
    fieldtype=map['fieldtype'];
    fieldvalue=map['fieldvalue'];
    checked=map['checked'];
    fileId=map['fileId'];
    serialNumber=map['serialNumber'];
    blocklength=map['blocklength'];
    BlocksLength=map['BlocksLength'];
  }
}

class memberTabledata{
  int id;
  String fileId;
  String batchName;
  String checked;
  String date;
  String name;
  memberTabledata({this.id,this.batchName,this.fileId,this.name,this.checked,this.date,});
  Map<String,dynamic> toMap(){
    var map=<String,dynamic>{
      'id':id,
      'fileId':fileId,
      'checked':checked,
      'name':name,
      'date':date,
      'batchName':batchName
    };
    return map;
  }

  memberTabledata.fromMap(Map<String,dynamic> map){
    id=map['id'];
    fileId=map['fileId'];
    name=map['name'];
    checked=map['checked'];
    date=map['date'];
    batchName=map['batcName'];
  }

}

class fileMetadata{
  int id;
  String fileId;
  String date;
  String batchName;
  fileMetadata({this.fileId,this.batchName,this.date,this.id});
  Map<String,dynamic> toMap(){
    var map=<String,dynamic>{
      'id':id,
      'date':date,
      'batchName':batchName,
      'fileId':fileId,
    };
    return map;    }
  fileMetadata.fromMap(Map<String,dynamic> map){
    id=map['id'];
    fileId=map['fileId'];
    batchName=map['batchName'];
    date=map['fileId'];
  }
}



/*
static int id;
  String date;
  String batchName;
  String title;
  String fieldtype;
  String fieldvalue;
  String fileId;
  bool fieldchecked;
  String member;
  bool checked;
 */
class databaseHelper {
  static Database _db;
  static final _dbName = 'database.db';
  static final _dbVersion = 1;
  static final _membersTable = 'membersTable';
  static final _blocksTable = 'blocksTable';
  static final _filesTable='filesTable';
  //making it a singleton class
  databaseHelper._privateConstructor();

  static final databaseHelper instance = databaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_db != null) return _db;
    _db = await _initiateDatabase();
    return _db;
  }

  Future _initiateDatabase() async {
    Directory path = await Directory('');
    String dbpath = join(path.path, _dbName);
    return await openDatabase(dbpath, version: _dbVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute("""
            CREATE TABLE ${_blocksTable} (
              id INTEGER PRIMARY KEY,
              serialNumber INTEGER NOT NULL,
              BlocksLength INTEGER NOT NULL,
              title TEXT NOT NULL,
              fieldtype TEXT NOT NULL,
              fieldvalue TEXT NOT NULL,
              blocklength INTEGER NOT NULL,
              checked TEXT NOT NULL,
              fileId TEXT NOT NULL
            )""");

    await db.execute("""
            CREATE TABLE ${_membersTable} (
              id INTEGER PRIMARY KEY,
              name TEXT NOT NULL,
              fileId TEXT NOT NULL,
              batchName TEXT NOT NULL,
              date TEXT NOT NULL,
              checked TEXT NOT NULL
            )""");

    await db.execute("""CREATE TABLE ${_filesTable}(
               id INTEGER PRIMARY KEY,
               batchName TEXT NOT NULL,
               fileId TEXT NOT NULL,
               date TEXT NOT NULL
          )""");
  }

  Future<int> insertFile(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(_membersTable, row);
  }

  Future<int> insertBlock(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(_blocksTable, row);
  }

  Future<int> insertFileMetadata(Map<String,dynamic> row) async{
    Database db=await instance.database;
    return await db.insert(_filesTable, row);
  }

  Future<List<Map<String, dynamic>>> queryFile(String filename) async {
    Database db = await instance.database;
    return await db.query(_membersTable, columns: [
      '$date','$checked','$fileId','$name','$id','$batchName'
    ], where: "$fileId=?",whereArgs: [filename]);
  }

  Future<List<Map<String, dynamic>>> queryBlocks(String filename) async{
    Database db = await instance.database;
    return await db.query(_blocksTable, where: 'fileId=?',whereArgs:[filename],);
  }

  Future updateFile(Map<String,dynamic> row,String filename) async{
    Database db = await instance.database;
    await db.update(_membersTable,row,where:'file=?',whereArgs:['${filename}']);
  }
  Future updateblock(Map<String,dynamic> row,String filename)async {
    Database db = await instance.database;
    await db.update(_blocksTable,row,where:'file=?',whereArgs:['${filename}']);
  }

  Future<List<Map<String,dynamic>>> queryAllFiles() async{
    Database db=await instance.database;
    return await db.query(_filesTable);
  }

  Future<int> deleteBlocks(String filename) async{
    Database db=await instance.database;
    print('HAS BEEN DELETED');
    return await db.delete(_blocksTable,where: 'fileId=?',whereArgs: [filename]);
  }
  Future deleteFiles(String filename) async{
    print("HAS BEEN DELETED 2");
    Database db=await instance.database;
    return await db.delete(_membersTable,where: 'fileId=?',whereArgs: [filename]);
  }

  Future deleteMetadata(String filename)async{
    Database db=await instance.database;
    return await db.delete(_filesTable,where: 'fileId=?',whereArgs: [filename]);
  }
}