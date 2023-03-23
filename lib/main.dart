import 'dart:async';
import 'dart:collection';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:naver_map_plugin/naver_map_plugin.dart';
import 'package:location/location.dart';
import 'CustomIcons.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CNU Bins',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key});
  @override
  State<StatefulWidget> createState() {
    return MyHomePageState();
  }
}

class MyHomePageState extends State<MyHomePage> {
  Completer<NaverMapController> _controller = Completer();
  NaverMapController? controllerInstance = null;
  // Select basic map (simple information)
  final MapType _mapType = MapType.Basic;
  Location location = Location();

  List<Marker> markers = [];

  NaverMap naverMap = NaverMap();
  int markerCount = 0;

  void addMarker() {
    controllerInstance?.getCameraPosition().then((value) {
      LatLng latlng = value.target;

      setState(() {
        Marker marker =
            Marker(markerId: markerCount.toString(), position: latlng);
        markers.add(marker);
        markerCount += 1;
      });

      markers.forEach((marker) {
        print(
            'lat: ${marker.position!.latitude}, lng: ${marker.position!.longitude}');
      });
    });
  }

  void addBin() {
    showDialog<String>(
        context: context,
        barrierColor: Colors.transparent,
        builder: (BuildContext context) => Dialog(
                child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Container(
                height: 300,
                child: Column(
                  children: [
                    Text(
                      '쓰레기통 종류를 선택해주세요',
                      style: TextStyle(fontSize: 20, color: Colors.black45),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 250,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.blue[300]),
                            onPressed: () => print('일반 쓰레기통 추가.'),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Text('일반 쓰레기'),
                                  SizedBox(
                                    height: 50,
                                  ),
                                  Icon(
                                    CustomIcons.trash,
                                    size: 80,
                                  )
                                ]),
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Container(
                            height: 250,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.blue[300]),
                              onPressed: () => print('분리수거함 추가.'),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text('분리수거함'),
                                    SizedBox(
                                      height: 50,
                                    ),
                                    Icon(
                                      CustomIcons.recycle,
                                      size: 80,
                                    )
                                  ]),
                            ))
                      ],
                    )
                  ],
                ),
              ),
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('CNU Bins')),
        body: Container(
          child: NaverMap(
            onMapCreated: onMapCreated,
            mapType: _mapType,
            markers: markers,
          ),
        ),
        floatingActionButton: Stack(
          children: <Widget>[
            MyFloatingButton(
                offsetY: Alignment.bottomRight.y - 0.2,
                icon: Icon(Icons.restore_from_trash),
                onPressed: addBin,
                parent: this),
            MyFloatingButton(
                offsetY: Alignment.bottomRight.y,
                icon: Icon(Icons.add_box_outlined),
                onPressed: addMarker,
                parent: this),
          ],
        ));
  }

  void onMapCreated(NaverMapController controller) {
    if (_controller.isCompleted) _controller = Completer();
    _controller.complete(controller);

    // Set location tracking mode to follow after loading naver map.
    controller.setLocationTrackingMode(LocationTrackingMode.Follow);

    controllerInstance = controller;
  }
}

class MyFloatingButton extends StatelessWidget {
  const MyFloatingButton(
      {super.key,
      required this.offsetY,
      required this.icon,
      required this.onPressed,
      required this.parent});
  final double offsetY;
  final Icon icon;
  final VoidCallback onPressed;
  final MyHomePageState parent;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(Alignment.bottomRight.x, offsetY),
      child: FloatingActionButton(
        child: icon,
        onPressed: onPressed,
      ),
    );
  }
}
