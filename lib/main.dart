import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late BehaviorSubject<List<int>> _dataSubject;
  late ScrollController _scrollController;
  Map<int, int> _dataList = {};
  final int _perPage = 30;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _dataSubject = BehaviorSubject<List<int>>();
    _scrollController = ScrollController()..addListener(_scrollListener);
    loadData(0);
  }

  @override
  void dispose() {
    _dataSubject.close();
    _scrollController.dispose();
    super.dispose();
  }

  void loadData(int startIndex, {bool prefetching = false}) {
    if (!_isLoading) {
      _isLoading = true;
      Future.delayed(const Duration(milliseconds: 100), () {
        Map<int, int> newData = {};
        for (int i = startIndex; i < startIndex + _perPage; i++) {
          newData[i] = i + 1; // Simulate fetching new data
        }

        // Merge new data into existing map
        _dataList.addAll(newData);

        // Since BehaviorSubject expects a List<int> but _dataList is a Map<int, int>,
        // we need to convert _dataList values to a List<int>.
        List<int> dataListValues = _dataList.values.toList();

        // Update the BehaviorSubject with the new list of data
        _dataSubject.add(dataListValues);
        _isLoading = false;
      }).catchError((error) {
        print('Error loading data: $error');
        _isLoading = false;
      });
    }
  }

  void _scrollListener() {
    if (_scrollController.position.atEdge) {
      bool isAtBottom = _scrollController.position.pixels == _scrollController.position.maxScrollExtent;
      if (isAtBottom && !_isLoading) {
        loadData(_dataList.length, prefetching: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Infinite Scroll Example'),
      ),
      body: StreamBuilder<List<int>>(
        stream: _dataSubject.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data!;
            return ListView.builder(
              controller: _scrollController,
              itemCount: data.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Item ${data[index]}'),
                );
              },
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
