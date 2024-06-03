import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
<<<<<<< HEAD
import 'package:cengproject/dbhelper/mongodb.dart'; // Ensure this import points to your MongoDB helper

class VideoStreamPage extends StatefulWidget {
  final String patientNumber;

  const VideoStreamPage({super.key, required this.patientNumber});
=======

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: VideoStreamPage(),
    );
  }
}

class VideoStreamPage extends StatefulWidget {
  const VideoStreamPage({super.key});
>>>>>>> main

  @override
  _VideoStreamPageState createState() => _VideoStreamPageState();
}

class _VideoStreamPageState extends State<VideoStreamPage> {
  List<int> _videoBytes = [];
  final StreamController<ui.Image> _imageStreamController = StreamController<ui.Image>.broadcast();
<<<<<<< HEAD
  Socket? _socket;
=======
  late Socket _socket;
>>>>>>> main
  bool _processing = false;
  bool _isConnected = false;
  String _connectionError = '';

  @override
  void initState() {
    super.initState();
    _initializeConnection();
  }

  Future<void> _initializeConnection() async {
    // Fetch the connection address using the patient number
    final connectionDetails = await MongoDatabase.getConnectionAddress(widget.patientNumber);
    if (connectionDetails.isNotEmpty) {
      final ip = connectionDetails['ip']!;
      final port = int.parse(connectionDetails['port']!);
      await _connectToServer(ip, port);
    } else {
      if (!mounted) return;
      setState(() {
        _isConnected = false;
        _connectionError = 'Error: No connection details found.';
      });
      if (kDebugMode) {
        print(_connectionError);
      }
    }
  }

  Future<void> _connectToServer(String ip, int port) async {
    try {
      _socket = await Socket.connect(ip, port);
      if (!mounted) return;

      setState(() {
        _isConnected = true;
        _connectionError = '';
      });

      _socket!.listen(
        (data) {
          if (!mounted) return;
          setState(() {
            _videoBytes.addAll(data);
          });
          if (!_processing) {
            _updateImage();
          }
        },
        onError: (error) {
          if (!mounted) return;
          if (kDebugMode) {
            print('Socket error: $error');
          }
          setState(() {
            _isConnected = false;
            _connectionError = 'Socket error: $error';
          });
        },
        onDone: () {
          if (!mounted) return;
          if (kDebugMode) {
            print('Connection closed');
          }
          setState(() {
            _isConnected = false;
            _connectionError = 'Connection closed';
          });
        },
      );
    } on SocketException {
      if (!mounted) return;
      setState(() {
        _isConnected = false;
        _connectionError = 'No Connection'; // error connecting to server $e
      });
      if (kDebugMode) {
        print(_connectionError);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isConnected = false;
        _connectionError = 'No Connection'; //unexpected error $e
      });
      //print(_connectionError);
    }
  }

  void _updateImage() async {
    _processing = true;
    try {
      while (_videoBytes.length >= 8) {
        final lengthData = _videoBytes.sublist(0, 8);
        final lengthBuffer = ByteData.sublistView(Uint8List.fromList(lengthData));
        final messageLength = lengthBuffer.getInt64(0, Endian.little);

        if (_videoBytes.length >= 8 + messageLength) {
          final imageData = _videoBytes.sublist(8, 8 + messageLength);
          _videoBytes = _videoBytes.sublist(8 + messageLength);

          // Decode the JPEG image
          final codec = await ui.instantiateImageCodec(Uint8List.fromList(imageData));
          final frame = await codec.getNextFrame();
          if (!mounted) return;
          _imageStreamController.add(frame.image);
        } else {
          break;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating image: $e');
      }
    } finally {
      _processing = false;
    }
  }

  Future<bool> _onWillPop() async {
    if (_isConnected) {
      _socket?.destroy();
    }
    return true; // Return true to allow the pop to happen
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Center(child: Text('Patient Video Stream')),
          automaticallyImplyLeading: false, // This removes the default back button on the left
        ),
        body: Center(
          child: _isConnected
              ? StreamBuilder<ui.Image>(
                  stream: _imageStreamController.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return SizedBox.expand(
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: snapshot.data!.width.toDouble(),
                            height: snapshot.data!.height.toDouble(),
                            child: CustomPaint(
                              painter: ImagePainter(image: snapshot.data!),
                            ),
                          ),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                )
              : Text(_connectionError.isEmpty ? 'No connection' : _connectionError),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            if (await _onWillPop()) {
              Navigator.of(context).pop();
            }
          },
          backgroundColor: Colors.red,
          child: const Icon(Icons.call_end),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
=======
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Video Stream'),
        automaticallyImplyLeading: false,  // This removes the default back button on the left
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Center(
        child: _isConnected
        ? StreamBuilder<ui.Image>(
          stream: _imageStreamController.stream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Center(
                child: CustomPaint(
                  size: const Size(300, 200),
                  painter: ImagePainter(image: snapshot.data!),
                ),
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            else {
              return const CircularProgressIndicator();
            }
          },
        )
            : const Text('No connection'),
>>>>>>> main
      ),
    );
  }

  @override
  void dispose() {
    _socket?.destroy();
    _imageStreamController.close();
    super.dispose();
  }
}

class ImagePainter extends CustomPainter {
  final ui.Image image;

  ImagePainter({required this.image});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw the image to fill the canvas
    final paint = Paint();
    canvas.drawImage(image, Offset.zero, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
