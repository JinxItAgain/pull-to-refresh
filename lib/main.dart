import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'MyData.dart';


click(BuildContext context, int index,List data) {
    // set up the buttons
    Widget deleteButton = TextButton(
      child: Text("Delete"),
      onPressed: () {

        Navigator.pop(context);
        return data.removeAt(index);

      },
    );
    Widget continueButton = TextButton(
      child: Text("Continue"),
      onPressed: () {},
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Delete Confirmation"),
      content: Text("Are you sure you want to delete this item?"),
      actions: [
        deleteButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
}
Future<List<MyData>> fetchData(http.Client client) async {
  final response = await client.get(Uri.parse('https://jsonplaceholder.typicode.com/todos'));

  // parseData to a separate isolate.
  return compute(parseData, response.body);
}

// response body to a List<MyData>.
List<MyData> parseData(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<MyData>((json) => MyData.fromJson(json)).toList();
}




void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = 'Parse App';

    return MaterialApp(
      title: appTitle,
      home: MyHomePage(title: appTitle),
    );
  }
}

class MyHomePage extends StatelessWidget {

  final String title;

  MyHomePage({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen.shade800,
        title: Text(title),
      ),
      body: FutureBuilder<List<MyData>>(
        future: fetchData(http.Client()),
        builder: (context, snapshot) {
          if (snapshot.hasError) print(snapshot.error);

          return snapshot.hasData
              ? TheList(data: snapshot.data)
              : Center(child: CupertinoActivityIndicator());
        },
      ),
    );
  }
}

class TheList extends StatelessWidget {
  final List<MyData> data;

  TheList({Key key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.lightGreen.shade50,

        child: ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            return Dismissible(
              child: Container(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 8,

                      child: Card(

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          color: Colors.lightGreen.shade100,
                          elevation: 10,
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text
                              ('''ID: ${data[index].id}
                            User ID: ${data[index].userId}
                            Title: ${data[index].title}
                            Completed: ${data[index].completed}
                          '''),
                          )
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: TextButton(onPressed: () {
                        click(context,index,data);
                      }, child: Text("Delete",)),),
                  ],
                ),

              ),
              key: ValueKey<MyData>(data[index]),
              confirmDismiss: (DismissDirection direction) async {
                return await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Delete Confirmation"),
                      content: const Text(
                          "Are you sure you want to delete this item?"),
                      actions: <Widget>[
                        TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text("Delete")
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text("Cancel"),
                        ),
                      ],
                    );
                  },
                );
              },
              onDismissed: (DismissDirection direction) {
                data.removeAt(index);
              },
            );
          },
        )

    );
  }


}
