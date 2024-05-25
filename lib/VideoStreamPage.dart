import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: VideoStreamPage(),
    );
  }
}

class VideoStreamPage extends StatefulWidget {
  const VideoStreamPage({super.key});

  @override
  _VideoStreamPageState createState() => _VideoStreamPageState();
}

class _VideoStreamPageState extends State<VideoStreamPage> {
  List<int> _videoBytes = [];
  final StreamController<ui.Image> _imageStreamController = StreamController<ui.Image>.broadcast();
  late Socket _socket;
  bool _processing = false;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _connectToServer();
  }

  Future<void> _connectToServer() async {
    try {
      // this is the IP address of the server but it wont be hardcoded in the final version
      _socket = await Socket.connect('192.168.10.10', 4545);
      setState((){
        _isConnected = true;
      });
      _socket.listen(
        (data) {
          setState(() {
            _videoBytes.addAll(data);
          });
          if (!_processing) {
            _updateImage();
          }
        },
        onError: (error) {
          print('Socket error: $error');
        },
        onDone: () {
          print('Connection closed');
        },
      );
    } catch (e) {
      setState(() {
        _isConnected = false;
        print('Error Connecting to server $e');
      });
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
          _imageStreamController.add(frame.image);
        } else {
          break;
        }
      }
    } catch (e) {
      print('Error updating image: $e');
    } finally {
      _processing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
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
      ),
    );
  }

  @override
  void dispose() {
    _socket.destroy();
    _imageStreamController.close();
    super.dispose();
  }
}

class ImagePainter extends CustomPainter {
  final ui.Image image;

  ImagePainter({required this.image});

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate the position to center the image
    final double x = (size.width - image.width) / 2;
    final double y = (size.height - image.height) / 2;
    canvas.drawImage(image, Offset(x, y), Paint());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
