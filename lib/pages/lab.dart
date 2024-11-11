import 'package:flutter/material.dart';
import 'dart:async';
import 'package:async/async.dart';

class MergedStreamExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    // Define two streams
    Stream<int> stream1 = Stream.periodic(Duration(seconds: 1), (count) => count).take(10);
    Stream<String> stream2 = Stream.periodic(Duration(milliseconds: 1500), (count) => 'Stream 2 - $count').take(10);

    // Merge streams
    var mergedStream = StreamGroup.merge([stream1, stream2]);

    return Scaffold(
      appBar: AppBar(title: Text('Merged Stream Example')),
      body: Center(
        child: StreamBuilder(
          stream: mergedStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasData) {
              if (snapshot.data is int){
                return Text('Latest data: Stream 1 - ${snapshot.data}');
              } else if (snapshot.data is String) {
                return Text('Latest data: ${snapshot.data}');
              }
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            return Text('No data');
          },
        ),
      ),
    );
  }
}
