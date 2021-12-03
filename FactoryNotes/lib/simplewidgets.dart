import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

bool fileChange=false;

class block extends StatefulWidget{

  Function field;
  int serialNumber;
  TextEditingController blocktitleController;
  String title;
  List blockItems=<InputFeild>[];
  List givenItems=<InputFeild>[];
  block({this.field,this.serialNumber,this.givenItems,this.title});
  @override
  blockState createState()=>blockState();
}

class blockState extends State<block> with AutomaticKeepAliveClientMixin<block>{
  TextEditingController blocktitleController=new TextEditingController();

  List texts=[null];
  List controllers=<TextEditingController>[];
  List<FocusNode> foculist=[];
  bool val =true;

  @override
  bool get wantKeepAlive => true;


  @override
  void initState() {
    widget.blocktitleController=new TextEditingController(text:widget.title??'');
    if(widget.givenItems!=null){
      widget.givenItems.forEach((element) {
        widget.blockItems.add(element);
      });
    }
    if(widget.blockItems.isEmpty){
      //texts.add('');
      widget.blockItems.add(InputFeild(index: 0,type: BoxType.shortText,));
    }
  }

  addTextfield(){
    if(widget.blockItems.length!=30){
      setState(() {
        widget.blockItems.add(InputFeild(index: widget.blockItems.length,remove:(index){
          removeFeild(index);
        } ,type: BoxType.shortText,),);

      });
    }
  }

  addActivitybox(){
    if(widget.blockItems.length!=30){
      setState(() {
        widget.blockItems.add(InputFeild(index: widget.blockItems.length,remove: (index){
          removeFeild(index);
        },type: BoxType.longText,));
      });

    }
  }


  removeFeild(int indx){
    if(widget.blockItems.length!=1){
      setState(() {
        widget.blockItems.removeAt(indx);
        //g776trddsxx
        print('CONTROLLERS ARE ${controllers.length}');
        print('BLOCKITEMS ARE ${widget.blockItems.length}');
        print('REMOVING AT INDEX ${indx}');
        int ind=0;
        widget.blockItems.forEach((element) {
          element.index=ind;
          ind++;
        });
      });
    }
  }
  addTextfeildWithCheck(){
    if(widget.blockItems.length!=30){
      setState(() {
        //texts.add('');
        print('LENGTH OF TEXTS IS ${texts.length}');
        print('OUR INDEX IS ${widget.blockItems.length}');
        widget.blockItems.add(
            InputFeild(
              index: widget.blockItems.length,remove:(index){
              removeFeild(index);
            } ,type: BoxType.checkbox,)
        );
      });
    }
  }




  @override
  Widget build(BuildContext context) {
    super.build(context);
    double height =MediaQuery.of(context).size.height;
    double width=MediaQuery.of(context).size.width;
    // TODO: implement build

    return new Center(child: new Stack(children: [
      ConstrainedBox(constraints:BoxConstraints(
          minHeight: height*0.3,
          minWidth: width*0.9,
          maxWidth: width*0.9
      ) ,child: new Container(
        child: new Card(
          color: Colors.white,
          child: new Container(
            padding: EdgeInsets.only(left: 23,right: 23,top:50,bottom: 10.0),
            child: Form(
              child: new Column(
                  children: widget.blockItems
              ),
            ),
          ),
        ),),),
      new Positioned(
          left: 10,
          top: -1,
          child: new GestureDetector(
              onLongPress: ()async {
                // a haptic feedback would be cool here
              },
              child: new ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: 60,
                    minHeight: 40,
                    maxWidth: width*0.4,
                    minWidth: 20
                ),
                child: new Container(
                    child: textInput2(controller: widget.blocktitleController,onChanged: (){
                      setState(() {
                        //widget.title=blocktitleController.text;
                      });
                    },),
                    padding: EdgeInsets.all(6.0),
                    decoration: new BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        color: Colors.blue,
                        boxShadow: [BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          offset: Offset(10,10),
                          blurRadius: 10,
                        )]
                    )),)
          )),
      new Positioned(
        right: 3.0,
        top: 8.0,
        child: new Container(
          height: 50,
          width: width*0.45,
          color: Colors.white,
          child: new Row(
            children: [
              new IconButton(icon: new Text('A',style: new TextStyle(fontWeight: FontWeight.bold,fontSize: 20),), onPressed:(){
                fileChange=true;
                addActivitybox();
              }),
              new IconButton(icon: Icon(Icons.title),onPressed: (){
                fileChange=true;
                addTextfield();
              },),

              new IconButton(icon: Icon(Icons.check),onPressed: (){
                //FocusScope.of(context).unfocus();
                fileChange=true;
                addTextfeildWithCheck();
              },)
            ],
          ),
        ),
      )
    ],),);
  }

}

class textInput extends StatefulWidget {
  int serialNumber;
  bool val = false;
  Function remove;
  String text;
  FocusNode node;
  Function textChanged;
  TextEditingController controller = new TextEditingController();
  int index;
  textInputState createState()=>textInputState();
  textInput({this.remove, @required this.index,
    this.node, this.textChanged,this.serialNumber,this.text=''});
}
class textInputState extends State<textInput>{

  @override
  Widget build(BuildContext context) {

    double height=MediaQuery.of(context).size.height;
    double width=MediaQuery.of(context).size.width;
    // TODO: implement build
    return new Container(
      height: height*0.07,
      width: width*0.8,
      child: new Row(children: [
        new Icon(Icons.remove).onTap(() {
          widget.controller.clear();
          widget.remove(widget.index);
        }),
        new Expanded(
          child:  VxTextField(
            onChanged: (v){
              setState(() {
                widget.textChanged(v);
              });
            },
            autofocus: false,
            borderType: VxTextFieldBorderType.none,
            fillColor: Colors.white,
            hint: 'Enter text',
            controller: widget.controller,
          ),
        )
      ],),
    );
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      widget.controller.text=widget.text;
    });
  }
}

class textInput2 extends StatelessWidget{
  TextEditingController controller;
  Function onChanged;
  textInput2 ({this.controller,this.onChanged});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return VxTextField(
      controller: controller,
      borderType: VxTextFieldBorderType.none,
      fillColor: Colors.blue,
      hint: 'Enter text',
      onChanged: (value){
        fileChange=true;
        onChanged();
      },
    );
  }
}

class bottom extends StatelessWidget{
  Function send;
  Function remove;
  Function add;
  bottom({this.remove,this.send,this.add});
  @override
  Widget build(BuildContext context) {
    double height=MediaQuery.of(context).size.height;
    double width=MediaQuery.of(context).size.width;

    // TODO: implement build
    return new Container(
      height: 60,
      width: 170,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          new InkWell(
            child: new Container(
              child: new Center(
                child: new Icon(Icons.send),
              ),
              decoration: BoxDecoration(
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1),
                      offset: Offset(10,10),
                      blurRadius: 10)],
                  color: Colors.green,
                  shape: BoxShape.circle
              ),
              height: 55,
              width: 55,
            ),
            onTap: (){
              send();
            },
          ),
          new InkWell(
            onTap: (){
              fileChange=true;
              remove();
            },
            child: new Container(
              child: new Center(
                child: new Icon(Icons.remove),
              ),
              decoration: BoxDecoration(
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1),
                      offset: Offset(10,10),
                      blurRadius: 10)],
                  color: Colors.orange,
                  shape: BoxShape.circle
              ),
              height: 55,
              width: 55,
            ),
          ),
          new InkWell(
            onTap: (){
              fileChange=true;
              add();
            },
            child: new Container(
              child: new Center(
                child: new Icon(Icons.add),
              ),
              decoration: BoxDecoration(
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1),
                      offset: Offset(10,10),
                      blurRadius: 10)],
                  color: Colors.pink,
                  shape: BoxShape.circle
              ),
              height: 55,
              width: 55,
            ),
          )
        ],),
    );
  }
}


class checkbox extends StatefulWidget {
  bool val = false;
  int index;
  String text;
  Function remove;
  Function checkedChanged;
  Function textChanged;
  String type = 'CHECKBOX';
  TextEditingController textEditingController=new TextEditingController();
  checkbox({this.remove, @required this.index,this.val,
    this.checkedChanged,this.textChanged,this.text=''});
  @override
  checkboxState createState()=>checkboxState();
}
class checkboxState extends State<checkbox>{
  TextEditingController _textEditingController;
  @override
  Widget build(BuildContext context) {
    double height=MediaQuery.of(context).size.height;
    double width=MediaQuery.of(context).size.width;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      //_textEditingController.text=text;
    });
    // TODO: implement build
    return new Container(
      height: height*0.07,
      width: width*0.8,
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 8,),
              new Icon(Icons.remove).onTap(() {
                print('i have been called to work');
                //widget.controller.clear();
                widget.remove(widget.index);
              }),
            ],
          ),
          new Expanded(
            child: CheckboxListTile(
                activeColor: Colors.black,
                title: VxTextField(
                  onChanged: (v){
                    //when the text changes we would call our super class function
                    //textchanged with the parameter text
                    widget.textChanged(v);
                  },
                  controller:widget.textEditingController,
                  /*
            prefixIcon: IconButton(icon: Icon(Icons.remove),onPressed: (){
              //FocusScope.of(context).unfocus();
              controller.clear();
              controller.dispose();
              //FocusScope.of(context).unfocus();
              remove(index);
            },)
            */
                  borderType: VxTextFieldBorderType.none,
                  fillColor: Colors.white,
                  hint: 'Enter text',
                ),
                value: widget.val, onChanged: (value){

              setState(() {
                fileChange=true;
                widget.checkedChanged(value);
                widget.val=value;
              });
              print('THE current value is${widget.val}');
            }),)
        ],
      ),
    );
  }
  @override
  void initState() {
    super.initState();
    _textEditingController=new TextEditingController();
    widget.textEditingController.text=widget.text;
  }

  @override
  void dispose() {
    //_textEditingController.dispose();
    super.dispose();
  }

}

class Activitybox extends StatefulWidget {
  String text='';
  TextEditingController controller = new TextEditingController();
  int index;
  int serialNumber;
  Function remove;
  Function textChanged;
  FocusNode node;
  Activitybox(
      {this.remove, @required this.index, this.node, this.serialNumber,
        this.textChanged,this.text=''});
  ActivityboxState createState()=>ActivityboxState();
}
class ActivityboxState extends State<Activitybox>{

  @override
  Widget build(BuildContext context) {

    double height=MediaQuery.of(context).size.height;
    double width=MediaQuery.of(context).size.width;
    // TODO: implement build
    return new Container(
      height: height*0.2,
      width: width*0.8,
      child: new Row(children: [
        new Icon(Icons.remove).onTap(() {
          widget.controller.clear();
          widget.remove(widget.index);
        }),
        new Expanded(
          child:    VxTextField(
            onChanged: (v){
              setState(() {
                widget.textChanged(v);
              });
            },
            maxLine: null,
            borderType: VxTextFieldBorderType.none,
            fillColor: Colors.white,
            hint: 'Enter Activity',
          ),
        )
      ],),
    );
  }

  @override
  void initState() {
    widget.controller.text=widget.text;
  }


}


class checkbox2 extends StatefulWidget {
  bool val = false;
  int index;
  String text;
  Function remove;
  String type = 'CHECKBOX2';
  //bool checked=false;
  //TextEditingController memberText=new TextEditingController();

  checkbox2({this.remove, @required this.index,this.val=true,this.text=''});
  @override
  checkboxState2 createState()=>checkboxState2();
}
class checkboxState2 extends State<checkbox2> with AutomaticKeepAliveClientMixin<checkbox2>{
  TextEditingController _textEditingController;


  @override
  bool get wantKeepAlive {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double height=MediaQuery.of(context).size.height;
    double width=MediaQuery.of(context).size.width;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      //_textEditingController.text=text;
    });
    // TODO: implement build
    return new Container(
      height: height*0.07,
      width: width*0.8,
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          new Expanded(
            child: CheckboxListTile(
                activeColor: Colors.black,
                title: VxTextField(
                  onChanged: (v)=>widget.text=v,
                  controller: _textEditingController,
                  /*
            prefixIcon: IconButton(icon: Icon(Icons.remove),onPressed: (){
              //FocusScope.of(context).unfocus();
              controller.clear();
              controller.dispose();
              //FocusScope.of(context).unfocus();
              remove(index);
            },)
            */
                  borderType: VxTextFieldBorderType.none,
                  fillColor: Colors.white,
                  hint: 'Enter text',
                ),
                value: widget.val, onChanged: (value){

              setState(() {
                fileChange=true;
                widget.val=value;
              });
              print('THE current value is${widget.val}');
            }),)
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _textEditingController=new TextEditingController(text: widget.text);
  }

  @override
  void dispose() {
    super.dispose();
  }


}

enum BoxType{
  checkbox,
  shortText,
  longText,
  checkbox2
}


/*
class checkbox3 extends StatefulWidget {
  bool val = false;
  int index;
  Function remove;
  BoxType type;
  //bool checked=false;
  TextEditingController memberText=new TextEditingController();

  checkbox3({this.remove, @required this.index,this.val=true,this.type});
  @override
  checkboxState3 createState()=>checkboxState3();
}
*/
class InputFeild extends StatefulWidget {
  //TextEditingController _textEditingController;
  String text = '';
  bool val = false;
  int index;
  Function remove;
  BoxType type;

  //bool checked=false;
  //TextEditingController memberText=new TextEditingController();
  InputFeildState createState()=>InputFeildState();
  InputFeild({this.remove, @required this.index, this.val = false,
    this.type,this.text=''});
}
class InputFeildState extends State<InputFeild>{
  @override
  Widget build(BuildContext context) {
    double height=MediaQuery.of(context).size.height;
    double width=MediaQuery.of(context).size.width;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      //_textEditingController.text=text;
    });
    // TODO: implement build
    switch(widget.type){
      case BoxType.checkbox:
        checkbox box=new checkbox(index: widget.index,
          remove: widget.remove,val: widget.val,
          text: widget.text,
          textChanged: (text){
            setState(() {
              fileChange=true;
              widget.text=text;
            });
          },checkedChanged: (val){
            setState(() {
              widget.val=val;
            });
          },);
        setState(() {
          //widget.text=box.textEditingController.text;
          //widget.val=box.val;
        });
        return box ;
        break;
      case BoxType.longText:
        Activitybox activitybox=new Activitybox(index: widget.index,remove: widget.remove,
          textChanged: (text){
            setState(() {
              fileChange=true;
              widget.text=text;
            });
          },text: widget.text,);
        //widget.text=activitybox.controller.text;
        return activitybox;
        break;
      case BoxType.shortText:
        textInput textinput=new textInput(index: widget.index,remove: widget.remove,
          textChanged: (text){
            setState(() {
              fileChange=true;
              widget.text=text;
            },);
          },text: widget.text,);
        //widget.text=textinput.controller.text;
        return textinput;
        break;
    }
  }


}