import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cengproject/dbhelper/mongodb.dart'; // Ensure this import points to your MongoDB helper

class VideoStreamPage extends StatefulWidget {
  final String patientNumber;

  const VideoStreamPage({super.key, required this.patientNumber});

  @override
  _VideoStreamPageState createState() => _VideoStreamPageState();
}

class _VideoStreamPageState extends State<VideoStreamPage> {
  List<int> _videoBytes = [];
  final StreamController<ui.Image> _imageStreamController = StreamController<ui.Image>.broadcast();
  Socket? _socket;
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
      setState(() {
        _isConnected = false;
        _connectionError = 'Error: No connection details found.';
      });
      print(_connectionError);
    }
  }

  Future<void> _connectToServer(String ip, int port) async {
    try {
      _socket = await Socket.connect(ip, port);
      setState(() {
        _isConnected = true;
        _connectionError = '';
      });
      _socket!.listen(
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
          setState(() {
            _isConnected = false;
            _connectionError = 'Socket error: $error';
          });
        },
        onDone: () {
          print('Connection closed');
          setState(() {
            _isConnected = false;
            _connectionError = 'Connection closed';
          });
        },
      );
    } on SocketException catch (e) {
      setState(() {
        _isConnected = false;
        _connectionError = 'Error connecting to server: $e';
      });
      print(_connectionError);
    } catch (e) {
      setState(() {
        _isConnected = false;
        _connectionError = 'Unexpected error: $e';
      });
      print(_connectionError);
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

  Future<bool> _onWillPop() async {
    if (_isConnected) {
      _socket?.destroy();
    }
    return true; // Return true to allow the pop to happen
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Patient Video Stream'),
          automaticallyImplyLeading: false, // This removes the default back button on the left
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () async {
                if (await _onWillPop()) {
                  Navigator.of(context).pop();
                }
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
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                )
              : Text(_connectionError.isEmpty ? 'No connection' : _connectionError),
        ),
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
