import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: appBar(), //back button
      body: listView(),
    );
  }

  PreferredSizeWidget appBar(){
    return AppBar(
      title: Text('Patient Notification'),
    );
  }

  Widget listView(){
    return ListView.separated(
        itemBuilder: (context, index){
      return listViewItem(index);
    },
    separatorBuilder: (context, index){
      return Divider(height: 10);
    },
    itemCount: 15);
  }

  Widget listViewItem(int index){
    return Container(
      margin: EdgeInsets.only(left:10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          message(index),
          timeAndDate(index),
        ],
      )
    );
  }

  Widget message(int index){
    double textSize = 14;
    return Container(
      child: RichText(
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          text: 'BED # ',
          style: TextStyle(
            fontSize: textSize,
            color: Colors.black,
            fontWeight: FontWeight.bold
          ),
          children: [
            TextSpan(
              text: 'Notification Description',
              style: TextStyle(
                fontWeight: FontWeight.w400,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget timeAndDate(int index){
    return Container(
      margin: EdgeInsets.only(top: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '03-05-2024',
              style: TextStyle(
                fontSize: 10,
              ),
          ),
          Text(
            '13:30',
            style: TextStyle(
              fontSize: 10,
            ),
          )
        ],
      )
    );
  }
}