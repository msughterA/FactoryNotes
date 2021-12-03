import 'package:FactoryNotes/main.dart';
import 'package:flutter/material.dart';
import 'simplewidgets.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:FactoryNotes/dataClass.dart';
import  'package:FactoryNotes/search.dart';
import 'importScreen.dart';
import 'homeScreen.dart';
import 'package:flutter/services.dart';
import 'package:velocity_x/velocity_x.dart';

Permission permissionFromString(String value){
  Permission permission;
  for (Permission item in Permission.values){
    if (item.toString()==value){
      permission=item;
    }
  }
  return permission;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SimplePermissions.requestPermission(permissionFromString('Permission.WriteExternalStorage'));
  await SimplePermissions.requestPermission(permissionFromString('Permission.ReadExternalStorage'));

  runApp(MaterialApp(home: Home(),));

}

class Home extends StatefulWidget{
  @override
  HomeState createState()=>new HomeState();

}

class HomeState extends State<Home>{
  List<Map<String,dynamic>> data;
  List<String> dates;
  List<String> _options=['delete'];
  String _selectedOption='';
  @override
  Widget build(BuildContext context) {
    double height=MediaQuery.of(context).size.height;
    double width=MediaQuery.of(context).size.width;
    // TODO: implement build
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.blueAccent,
        leading: new Center(child: new Text('Files'),),
        actions: [
          dates==null?new Container():IconButton(icon: Icon(Icons.search),onPressed: (){
            showSearch(context: context,delegate: DataSearch(dates: dates,maps:data,isTemplate: false));
          },)
        ],),
      body: new Container(
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

                    return ListTile(title: new Text('${snapshot.data[index]['date']}'),
                      dense: true,
                      leading: new Icon(Icons.file_present),
                      trailing:DropdownButtonHideUnderline(child:DropdownButton(
                        items: _options.map((e){
                          return DropdownMenuItem(child: new Text(e),
                            value: e,
                          );
                        }).toList(), onChanged: (value){
                        setState(() {
                          _selectedOption=value;
                          if(_selectedOption=='delete'){
                            //widget.engine.Delete('playlists/${snapshot.data[index]['playlist']}');
                            databaseHelper.instance.deleteFiles(snapshot.data[index]['fileId']);
                            databaseHelper.instance.deleteBlocks(snapshot.data[index]['fileId']);
                            databaseHelper.instance.deleteMetadata(snapshot.data[index]['fileId']);
                          }
                        });
                      },
                        icon:  Icon(Icons.more_vert),
                        isDense: false,
                      )),
                      subtitle: new Text('${snapshot.data[index]['batchName']}'),onTap: (){
                        Navigator.of(context).push(MaterialPageRoute(builder: (context)=>MyApp(fileId:snapshot.data[index]['fileId'] ,)));
                      },);
                  });
            }),
      ),

      floatingActionButton: new FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: (){
          //blockTabledata blocksdata=new blockTabledata(title: 'euueue',checked: 'TRUE',fieldtype: 'kdkdk',fieldvalue: 'idiei',fileId: 'eidn',id: 0);
          //databaseHelper.instance.insertBlock(blocksdata.toMap());
          //print('WROTE TO DATABASE SUCCESSFULLY');
          Navigator.of(context).push(MaterialPageRoute(builder: (context)=>MyApp()));
        },
        child: new Icon(Icons.add,color: Colors.white,),
      ),
    );
  }

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp,DeviceOrientation.portraitDown]);
    databaseHelper.instance.queryAllFiles().then((List files){
      data=[];
      dates=[];
      print(files.length);
      print('THIS ARE THE FILES ${files}');
      setState(() {
        data=files;
      });
      files.forEach((element){
        //print(element['batchName']);
        //data.add({'date':element['date'],'batchName':element['batchName']});
        setState(() {
          dates.add(element['date']);
        });
        print('THE FILEID IS ${element['fileId']} THE BATCHNAME IS ${element['date']}');
      });
    });
  }


}


