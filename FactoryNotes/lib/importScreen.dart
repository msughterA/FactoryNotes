import 'package:flutter/material.dart';
import 'package:FactoryNotes/dataClass.dart';
import 'package:FactoryNotes/main.dart';
import 'search.dart';
import 'homeScreen.dart';

class FilesList extends StatefulWidget{
  @override
  FilesListState createState()=> new FilesListState();
}

class FilesListState extends State<FilesList>{
  List<String> dates;
  List<Map<String,dynamic>> maps;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    databaseHelper.instance.queryAllFiles().then((Values){
      dates=<String>[];
      setState((){
        maps=Values;
      });
      //List<Map<String,dynamic>> vals=Values.where((element)=>element);
      Values.forEach((element){
        setState(() {
          dates.add(element['date']);
        });
      });
    });
  }
  @override
  Widget build(BuildContext context){
    double height=MediaQuery.of(context).size.height;
    double width=MediaQuery.of(context).size.width;
    return new Scaffold(
        appBar: new AppBar(
          backgroundColor: Colors.blueAccent,
          leading: new IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: (){
              //GO BACK HOME
              Navigator.pop(context);
            },
          ),
          actions: [dates==null?new Container():IconButton(icon: Icon(Icons.search),onPressed: (){
            showSearch(context: context,delegate: DataSearch(dates: dates,maps:maps));
          },)],
        ),
        body:new Container(
          height:height ,
          width: width,
          child: new StreamBuilder(
              stream: databaseHelper.instance.queryAllFiles().asStream(),
              builder: (context,snapshot){
                if(!snapshot.hasData){
                  return new Center(child: new CircularProgressIndicator(),);
                }
                return snapshot.data.isEmpty? new Center(child: new Text('add a new document'),):new ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context,index){
                      return ListTile(title: new Text('${snapshot.data[index]['date']}'),subtitle: new Text('${snapshot.data[index]['batchName']}'),onTap: (){
                        Navigator.of(context).push(MaterialPageRoute(builder:
                            (context)=>MyApp(fileId:snapshot.data[index]['fileId'] ,isTemplate: true,)));
                      },);
                    });
              }),
        )
    );
  }
}