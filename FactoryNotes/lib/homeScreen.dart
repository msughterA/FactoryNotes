import 'package:FactoryNotes/dataClass.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:FactoryNotes/simplewidgets.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'homeScreen.dart';
import 'package:FactoryNotes/importScreen.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:intl/intl.dart';
import 'main.dart';
//import 'package:advanced'



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SimplePermissions.requestPermission(permissionFromString('Permission.WriteExternalStorage'));
  await SimplePermissions.requestPermission(permissionFromString('Permission.ReadExternalStorage'));
  runApp(MaterialApp(home: MyApp(),));
}

Permission permissionFromString(String value){
  Permission permission;
  for (Permission item in Permission.values){
    if (item.toString()==value){
      permission=item;
    }
  }
  return permission;
}



class MyApp extends StatefulWidget{
  bool isTemplate=false;

  String fileId;
  MyApp({this.fileId,this.isTemplate=false});
  @override
  AppState createState()=> AppState();
}

class AppState extends State<MyApp>{
  Permission _permissionRead;
  Permission _permissionWrite;
  String date='';
  String members='';
  TextEditingController _dateController=TextEditingController();
  TextEditingController _batchController=TextEditingController();
  TextEditingController _membersController=TextEditingController();
  TextEditingController _dialogTextController=TextEditingController();
  List blocks=<block>[];
  List blockTitleControllers=<TextEditingController>[];
  String currentdialogText='';
  DateTime selectedDate=DateTime.now();
  List<checkbox2> Batch=[];
  bool hasFile=false;
  bool shouldSave=false;
  bool showTools=true;
  String fileId;
  String dateTime=DateTime.now().microsecondsSinceEpoch.toString();

  @override
  void initState() {
    _permissionRead=permissionFromString('Permission.ReadExternalStorage');
    _permissionWrite=permissionFromString('Permission.WriteExternalStorage');

    super.initState();

    setState(() {
      fileChange=false;
    });
    //print('THIS IS HOW THE REGEX WORKS ${getVariableName('epeonoeeipeip::jfjfifofor')}');
    if(widget.fileId!=null && widget.isTemplate==false){
      fileId=widget.fileId;
      hasFile=true;
      shouldSave=false;
      print('THE FILEID IS NOT NULL${widget.fileId}');
      databaseHelper.instance.queryFile(widget.fileId).then((values){
        print('WE HAVE ELEMENTS IN THE FILE ${values.isEmpty}');
        widget.isTemplate?'': _dateController.text=values[0]['date'];
        _batchController.text=values[0]['batchName'];
        values.forEach((element) {
          print('SAMPLE ELEMENT NAME IS ${element['name']}');
          Batch.add(checkbox2(
            text:element['name'] ,
            val: widget.isTemplate?false:(element['checked']=='TURE'?true:false),
          ));
        });
      }).catchError((error){
        print('THIS IS THE ERROR ${error}');
      });
      databaseHelper.instance.queryBlocks(widget.fileId).then((values){
        print('IS THE LIST VALUES EMPTY${values.isEmpty}');
        int serialNumber=values[0]['serialNumber'];
        int blockCount=values[0]['BlocksLength'];

        for(int i=0;i<blockCount;i++){
          List<InputFeild> blockItems=[];
          List<Map<String,dynamic>> items=values.where((element) => element['serialNumber']==i).toList();

          print('IS THE LIST ITEMS EMPTY ${items.isEmpty}');
          items.forEach((element) {
            print('THE FEILD VALUE IS ${element['fieldvalue']}');
            blockItems.add(InputFeild(
                text: widget.isTemplate?('BoxType.checkbox'!=element['fieldtype']?getVariableName(element['fieldvalue']):element['fieldvalue']):element['fieldvalue'],
                index: element['index'],
                val: widget.isTemplate?false:(element['checked']=='TRUE'?true:false),
                type: determineType(element['fieldtype'],
                )));
          });

          print('SOMETHING WENT WRONG');
          setState(() {
            blocks.add(block(givenItems: blockItems,title: items[0]['title'],
            ));
          });
        }

      });
    }
    else{
      Batch.add(checkbox2(index: 0,));
      fileId=_dateController.text + _batchController.text + dateTime;
    }

  }

  /*
  *  blocks.add(InputFeild(
            text: element['feildvalue'],
            index: element['index'],
            val: element['checked']=='TRUE'?true:false,
            type: determineType(element['fieldtype'],
            ),
          ));
          */

  determineType(String type){
    switch (type){
      case 'BoxType.checkbox':
        return BoxType.checkbox;
        break;
      case 'BoxType.longText':
        return BoxType.longText;
        break;
      case 'BoxType.shortText':
        return BoxType.shortText;
        break;
    }
  }
  Future _selectDate(BuildContext context) async{
    final DateTime picked=await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(2015),
        lastDate: DateTime(2101)
    );
    if(picked!=null){
      setState(() {
        selectedDate=picked;
        _dateController.text=DateFormat().add_yMd().format(selectedDate);
      });
    }
  }

  getVariableName(String text){
    RegExp exp=new RegExp(r'(\w+)(:{2})');
    RegExpMatch match=exp.firstMatch(text);
    if(match!=null){
      return match.group(0);
    }
    else{
      return '';
    }

  }

  addblock(BuildContext context) async{
    setState(() {
      blocks.add(block(field: (){},));
    });
  }
  removeblock(BuildContext context){
    setState(() {
      blocks.removeLast();
    });
  }
  shareToWhatsapp(BuildContext context){
    final RenderBox box=context.findRenderObject();
    String string=processDoc();
    Share.share(string,subject: 'Dangote Cement plant data',
        sharePositionOrigin: box.localToGlobal(Offset.zero)& box.size);
  }


  processDoc(){
    String names='';
    String blocktext='';
    Batch.forEach(
            (element){
          if(element.val==true){
            names=names+'${element.text},\n';
          }

          print('ELEMENT TEXT IS ${names+element.text}');
        }
    );
    blocks.forEach((element){
      blocktext=blocktext+ '${element.blocktitleController.text.toString().toUpperCase()}:\n';
      element.blockItems.forEach((feild){
        if(feild.type.toString()=='BoxType.checkbox'){
          if(feild.val==true){
            blocktext=blocktext+'\t${feild.text}\n';
          }
        }
        else{
          blocktext=blocktext+'\t${feild.text}\n';
        }
      });
      blocktext=blocktext+'\n';

    });
    String doc='''Date:${_dateController.text}
BatchName:${_batchController.text}
BatchMembers:${names}''';

    return doc+blocktext;
  }
  saveDoc() async{
    if(hasFile==false) {
      print('BATCH LENGTH IS ${Batch.length}');
      fileMetadata metadata=fileMetadata(batchName: _batchController.text,date: _dateController.text,fileId: fileId);
      databaseHelper.instance.insertFileMetadata(metadata.toMap());
      Batch.forEach((element) async{
        //print(element.memberText.text);
        memberTabledata memberdata = new memberTabledata(fileId: fileId,
            batchName: _batchController.text,
            name: element.text,
            checked: element.val == true ? 'TURE' : 'FALSE',
            date: _dateController.text);
        await databaseHelper.instance.insertFile(memberdata.toMap());
        print('${element.text} SAVED SUCCESSFULY');
        print('THIS IS THE BATCH CONTROLLER TEXT ${_batchController.text}');
      });
      int count = 0;
      blocks.forEach((element) {
        //element.ene;
        element.blockItems.forEach((field) async{
          //print('TEXT:${element.text} VAL:${element.val}');
          print('field BEFORE type is ${field.type.toString()}');
          blockTabledata blocktabledata = new blockTabledata(
              title: element.blocktitleController.text,
              checked: field.val == true ? 'TRUE' : 'FALSE',
              fileId: fileId,
              fieldvalue: field.text,
              fieldtype: field.type.toString(),
              serialNumber: count,
              blocklength: element.blockItems.length,
              BlocksLength: blocks.length);
          await databaseHelper.instance.insertBlock(blocktabledata.toMap());
          print('field type is ${field.type.toString()}');
          print('BLOCK TITLE IS ${element.blocktitleController.text}');
        });
        count++;
      });
      setState(() {
        hasFile=true;
        fileId=_dateController.text + _batchController.text + dateTime;
        widget.fileId=fileId;
        fileChange=false;
      });
      context.showToast(msg: 'file saved');
    }
    else if(hasFile==true && fileChange==true){
      await dialog(context);
      if(shouldSave==true){
        await databaseHelper.instance.deleteFiles(widget.fileId);

        //await databaseHelper.instance.deleteBlocks(widget.fileId);
        fileMetadata metadata=fileMetadata(batchName: _batchController.text,date: _dateController.text,fileId: widget.fileId);
        await databaseHelper.instance.deleteMetadata(widget.fileId);
        Batch.forEach((element) async{
          //print(element.memberText.text);
          memberTabledata memberdata = new memberTabledata(fileId: widget.fileId,
              batchName: _batchController.text,
              name: element.text,
              checked: element.val == true ? 'TURE' : 'FALSE',
              date: _dateController.text);
          await databaseHelper.instance.insertFile(memberdata.toMap());
          print('${element.text} SAVED SUCCESSFULY');
          print('THIS IS THE BATCH CONTROLLER TEXT ${_batchController.text}');
        });
        int count = 0;
        await databaseHelper.instance.deleteBlocks(widget.fileId);
        blocks.forEach((element) {
          //element.ene;
          element.blockItems.forEach((field) async{
            //print('TEXT:${element.text} VAL:${element.val}');
            print('field BEFORE type is ${field.type.toString()}');
            blockTabledata blocktabledata = new blockTabledata(
                title: element.blocktitleController.text,
                checked: field.val == true ? 'TRUE' : 'FALSE',
                fileId: widget.fileId,
                fieldvalue: field.text,
                fieldtype: field.type.toString(),
                serialNumber: count,
                blocklength: element.blockItems.length,
                BlocksLength: blocks.length);
            await databaseHelper.instance.insertBlock(blocktabledata.toMap());
            print('field type is ${field.type.toString()}');
            print('BLOCK TITLE IS ${element.blocktitleController.text}');
          });
          count++;
        });
        setState(() {
          hasFile=true;
          fileId=_dateController.text + _batchController.text + dateTime;
          widget.fileId=fileId;
          fileChange=false;
        });
        await databaseHelper.instance.insertFileMetadata(metadata.toMap());
        context.showToast(msg: 'file saved');
      }
      else{
        //DO SOMETHING ELSE OTHER THAN SAVING THAT DOCUMENT
      }


    }
  }
  @override
  Widget build(BuildContext context) {
    double height=MediaQuery.of(context).size.height;
    double width=MediaQuery.of(context).size.width;
    double expandedHeight=225;

    // TODO: implement build
    return new Scaffold(
      body: new Stack(children: [
        new Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: new CustomScrollView(
              slivers:<Widget>[
                SliverAppBar(
                  backgroundColor: Colors.blueGrey,
                  expandedHeight: expandedHeight,
                  pinned: true,
                  floating: true,
                  title: new Text('shift ${date}',style: new TextStyle(color: Colors.white),),
                  flexibleSpace: FlexibleSpaceBar(

                    //collapseMode: CollapseMode.parallax,
                    background: Container(
                      color: Colors.white,
                      padding: EdgeInsets.only(top: 50,right: 23,left: 23,bottom: 23),
                      child: Column(
                        children: <Widget>[
                          new Container(
                            width: width,
                            height: height*0.07,
                            child: new Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                new IconButton(onPressed: (){
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=>FilesList()));
                                },icon: Icon(Icons.save_alt),),
                                new IconButton(onPressed: (){
                                  if(fileChange==true && hasFile==true){
                                    dialogH(context);
                                  }
                                  else{
                                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Home()));
                                  }
                                },icon: Icon(Icons.home_outlined),),
                                new IconButton(onPressed: (){
                                  saveDoc();

                                },icon: Icon(Icons.check),),
                                new IconButton(icon: Icon(Icons.palette), onPressed: (){
                                  setState(() {
                                    //expandedHeight=expandedHeight+ height*0.07;
                                    showTools=!showTools;
                                  });
                                })
                              ],
                            ),
                          ),
                          new SizedBox(height: 2,),
                          new Container(
                              height: height*0.04,
                              width: width*0.72,
                              child: VxTextField(
                                onChanged: (v){
                                  fileChange=true;
                                },
                                controller: _dateController,
                                prefixIcon: IconButton(icon: Icon(Icons.add,color: Colors.black,),onPressed: () async{
                                  await _selectDate(context);
                                  setState(() {
                                    print('was called');
                                    //print('controller text is ${_dateController.text}');
                                    date=_dateController.text;
                                    //date='hello';
                                  });
                                },),
                                borderType: VxTextFieldBorderType.none,
                                fillColor: Colors.white,
                                hint: 'Date',
                              )
                          ),
                          new Container(
                            height: height*0.1,
                            width: width*0.72,
                            constraints: BoxConstraints(
                              minHeight: height*0.05,
                              minWidth: width*0.72,
                              maxWidth: width*0.72,
                            ),
                            child:    new Container(
                              height: height*0.07,
                              width: width*0.6,
                              child: new Row(children: [
                                new SizedBox(width: 10,),
                                new Icon(Icons.add).onTap(() {
                                  addMembereDialog(context,Batch);
                                }),
                                new Container(
                                  height: height*0.06,
                                  width: width*0.5,
                                  child:  VxTextField(
                                    onChanged: (v){
                                      fileChange=true;
                                    },
                                    controller: _batchController,
                                    autofocus: false,
                                    borderType: VxTextFieldBorderType.none,
                                    fillColor: Colors.white,
                                    hint: 'BatchName ',
                                  ),
                                ),

                              ],),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => blocks[index],
                    // Builds 1000 ListTiles,
                    addAutomaticKeepAlives: true,
                    addRepaintBoundaries: true,
                    childCount: blocks.length,
                  ),
                )
              ]
          ),
        ),
        showTools==true?new Positioned(
          bottom: 25,
          right: 20,
          child: bottom(send: (){
            //Send the Data to a particular whatsapp number
            shareToWhatsapp(context);
          },
            add: (){
              addblock(context);
            },
            remove: (){
              //Function to remove text block would be added here
              removeblock(context);
            },),
        ):new Container(),
      ],),
    );
  }
  dialog(BuildContext context) async {
    currentdialogText='';
    _dialogTextController.clear();
    return showDialog(context: context, builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0)
        ),
        child: Container(
          height: 200,
          width: 200,
          padding: EdgeInsets.all(20.0),
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Container(
                child: new Text('Do you want to save changes to the document'),
                width: 150,),
              new SizedBox(height: 10,),
              new Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  new RaisedButton(
                    child: new Text('ok',style:new TextStyle(color: Colors.white)),
                    onPressed: ()async {
                      //Ovewrite the document
                      setState(() {
                        shouldSave=true;
                        hasFile=true;
                        widget.fileId=fileId;
                      });
                      //saveDoc();
                      Navigator.pop(context);
                      //Navigator.of(context).popUntil((route) => route.isFirst);
                      //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Home()));
                    },color: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0)
                    ),),
                  new RaisedButton(
                    child: new Text('cancel',style: new TextStyle(color: Colors.white),),
                    onPressed: (){
                      //Don't overwrite the document
                      setState(() {
                        shouldSave=false;
                      });
                      //Navigator.of(context).popUntil((route) => route.isFirst);
                      //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Home()));
                      Navigator.pop(context);
                    },color: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0)
                    ),)
                ],)
              //new Center(child: ,)
            ],),
        ),
      );
    });
  }

  addMembereDialog(BuildContext context,List<Widget> batch){

    double height=MediaQuery.of(context).size.height;
    double width=MediaQuery.of(context).size.width;
    double dialogheight=height*0.2;

    if(Batch.isEmpty){
      print('THE BATCH IS EMPTY IS ${Batch.isEmpty}');
      batch.add(checkbox2(index: 0,));
      dialogheight=height*0.2;
    }
    else{
      setState(() {
        //batch=this.Batch;
        dialogheight=(dialogheight+(height*0.08)*Batch.length);
      });
    }

    return showDialog(context: context, builder: (BuildContext context) {
      print('WE ARE IN SHOW DIALOG');

      return Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0)
        ),
        child: new StatefulBuilder(builder: (context,setState){

          return new Stack(
            children: [
              Container(
                height: dialogheight,
                width: width*0.8,
                padding: EdgeInsets.all(20.0),
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    new SizedBox(height: 15,),
                    new Expanded(child: new SingleChildScrollView(
                      child: new Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: Batch,
                      ),
                      scrollDirection: Axis.vertical,
                    )),
                    new SizedBox(height: 10,),
                    Align(child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        new RaisedButton(
                          child: new Text('ok',style:new TextStyle(color: Colors.white)),
                          onPressed: ()async {
                            //Ovewrite the document
                            Navigator.pop(context);
                            //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Home()));
                          },color: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0)
                          ),),
                        new RaisedButton(
                          child: new Text('cancel',style: new TextStyle(color: Colors.white),),
                          onPressed: (){
                            //Don't overwrite the document
                            Navigator.pop(context);
                          },color: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0)
                          ),)
                      ],),
                      alignment: Alignment.bottomCenter,)
                  ],
                ),
              ),
              new Positioned(child: new Row(
                children: [
                  new IconButton(icon: Icon(Icons.add), onPressed: (){
                    setState((){
                      if(batch.length<=6){
                        setState((){
                          dialogheight=dialogheight+(height*0.08);
                          batch.add(checkbox2(index: batch.length));
                        });
                      }
                      else{
                        setState((){
                          batch.add(checkbox2(index: batch.length));
                        });
                      }
                    });
                  }),
                  new IconButton(icon: Icon(Icons.remove), onPressed: (){
                    if(Batch.length!=1){
                      setState((){
                        Batch.removeLast();
                        dialogheight=dialogheight-(height*0.08);
                      });
                    }
                  })
                ],
              ),top:1,right: 1,)
            ],
          );
        }),
      );
    });
  }
  dialogH(BuildContext context) async {
    currentdialogText='';
    _dialogTextController.clear();
    return showDialog(context: context, builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0)
        ),
        child: Container(
          height: 200,
          width: 200,
          padding: EdgeInsets.all(20.0),
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Container(
                child: new Text('Do you want to save changes to the document'),
                width: 150,),
              new SizedBox(height: 10,),
              new Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  new RaisedButton(
                    child: new Text('ok',style:new TextStyle(color: Colors.white)),
                    onPressed: ()async {
                      //Ovewrite the document
                      setState(() {
                        shouldSave=true;
                      });
                      if (hasFile==false) {
                        print('BATCH LENGTH IS ${Batch.length}');
                        fileMetadata metadata=fileMetadata(batchName: _batchController.text,date: _dateController.text,fileId: fileId);
                        databaseHelper.instance.insertFileMetadata(metadata.toMap());
                        Batch.forEach((element) async{
                          //print(element.memberText.text);
                          memberTabledata memberdata = new memberTabledata(fileId:fileId,
                              batchName: _batchController.text,
                              name: element.text,
                              checked: element.val == true ? 'TURE' : 'FALSE',
                              date: _dateController.text);
                          await databaseHelper.instance.insertFile(memberdata.toMap());
                          print('${element.text} SAVED SUCCESSFULY');
                          print('THIS IS THE BATCH CONTROLLER TEXT ${_batchController.text}');
                        });
                        int count = 0;
                        blocks.forEach((element) {
                          //element.ene;
                          element.blockItems.forEach((field) async{
                            //print('TEXT:${element.text} VAL:${element.val}');
                            print('field BEFORE type is ${field.type.toString()}');
                            blockTabledata blocktabledata = new blockTabledata(
                                title: element.blocktitleController.text,
                                checked: field.val == true ? 'TRUE' : 'FALSE',
                                fileId: fileId,
                                fieldvalue: field.text,
                                fieldtype: field.type.toString(),
                                serialNumber: count,
                                blocklength: element.blockItems.length,
                                BlocksLength: blocks.length);
                            await databaseHelper.instance.insertBlock(blocktabledata.toMap());
                            print('field type is ${field.type.toString()}');
                            print('BLOCK TITLE IS ${element.blocktitleController.text}');
                          });
                          count++;
                        });
                        setState(() {
                          hasFile=true;
                          fileId=_dateController.text + _batchController.text + dateTime;
                          widget.fileId=fileId;
                        });
                      }
                      else if(hasFile==true && fileChange==true){
                        //await dialog(context);
                        if(shouldSave==true){
                          await databaseHelper.instance.deleteFiles(widget.fileId);
                          //await databaseHelper.instance.deleteBlocks(widget.fileId);
                          fileMetadata metadata=fileMetadata(batchName: _batchController.text,date: _dateController.text,fileId: widget.fileId);
                          await databaseHelper.instance.deleteMetadata(widget.fileId);
                          print('BATCH LENGTH IS ${Batch.length}');
                          Batch.forEach((element) async{
                            //print(element.memberText.text);
                            memberTabledata memberdata = new memberTabledata(fileId: widget.fileId,
                                batchName: _batchController.text,
                                name: element.text,
                                checked: element.val == true ? 'TURE' : 'FALSE',
                                date: _dateController.text);
                            await databaseHelper.instance.insertFile(memberdata.toMap());
                            print('${element.text} SAVED SUCCESSFULY');
                            print('THIS IS THE BATCH CONTROLLER TEXT ${_batchController.text}');
                          });
                          int count = 0;
                          await databaseHelper.instance.deleteBlocks(widget.fileId);
                          blocks.forEach((element) {
                            //element.ene;
                            element.blockItems.forEach((field) async{
                              //print('TEXT:${element.text} VAL:${element.val}');
                              print('field BEFORE type is ${field.type.toString()}');
                              blockTabledata blocktabledata = new blockTabledata(
                                  title: element.blocktitleController.text,
                                  checked: field.val == true ? 'TRUE' : 'FALSE',
                                  fileId: widget.fileId,
                                  fieldvalue: field.text,
                                  fieldtype: field.type.toString(),
                                  serialNumber: count,
                                  blocklength: element.blockItems.length,
                                  BlocksLength: blocks.length);
                              await databaseHelper.instance.insertBlock(blocktabledata.toMap());
                              print('field type is ${field.type.toString()}');
                              print('BLOCK TITLE IS ${element.blocktitleController.text}');
                            });
                            count++;
                          });
                          setState(() {
                            hasFile=true;
                            fileId=_dateController.text + _batchController.text + dateTime;
                            widget.fileId=fileId;
                          });
                          await databaseHelper.instance.insertFileMetadata(metadata.toMap());
                        }
                        else{
                          //DO SOMETHING ELSE OTHER THAN SAVING THAT DOCUMENT
                        }


                      }
                      //Navigator.pop(context);
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Home()));
                    },color: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0)
                    ),),
                  new RaisedButton(
                    child: new Text('cancel',style: new TextStyle(color: Colors.white),),
                    onPressed: (){
                      //Don't overwrite the document
                      setState(() {
                        shouldSave=false;
                      });
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Home()));
                    },color: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0)
                    ),)
                ],)
              //new Center(child: ,)
            ],),
        ),
      );
    });
  }
}