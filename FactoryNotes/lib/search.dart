import 'package:flutter/material.dart';
import 'main.dart';
import 'homeScreen.dart';


class DataSearch extends SearchDelegate<String>{
  List<String> dates;
  List<Map<String,dynamic>> maps;
  bool isTemplate;
  DataSearch({this.dates,this.maps,this.isTemplate=true});
  @override
  List<Widget> buildActions(BuildContext context){
    return [
      IconButton(icon: Icon(Icons.clear,),onPressed: (){
        query='';
      },)
    ];
  }

  @override
  Widget buildLeading(BuildContext context){
    return IconButton(icon: AnimatedIcon(icon:AnimatedIcons.menu_arrow ,progress:transitionAnimation,),
      onPressed:(){
        Navigator.pop(context);
      },);
  }
  @override
  Widget buildResults(BuildContext context){

  }

  @override
  Widget buildSuggestions(BuildContext context){

    //query.isEmpty?recentCities:cities.where((p)=> p.startsWith(query));
    final List<String>suggestionList=query.isEmpty ?dates:dates.where((p)=> p.startsWith(query)).toList();
    //final List<Map<String,dynamic>> suggestionList2=query.isEmpty?:;
    return ListView.builder(
      itemBuilder: (context,index){

        return ListTile(
          onTap: (){
            Map<String,dynamic> fileId= maps.firstWhere((element)=>element['date']==suggestionList[index]);
            if(isTemplate=true){
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>MyApp(fileId:fileId['fileId'] ,isTemplate: true,)));
            }
            else{
              Navigator.of(context).push(MaterialPageRoute(builder: (context)=>MyApp(fileId:fileId['fileId'] ,isTemplate: false,)));
            }
          },
          leading:Icon(Icons.calendar_today_outlined),
          title: RichText(text: TextSpan(
              text: suggestionList[index].substring(0,query.length),
              style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
              children: [TextSpan(text: suggestionList[index].substring(query.length),
                  style: TextStyle(color: Colors.grey)),]
          ),),
        );},
      itemCount: suggestionList.length,
    );
  }
}