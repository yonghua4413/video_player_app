import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '视频播放器',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const VideoPlayerScreen(),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  bool _isVideoLoaded = false;
  bool _isDragging = false;

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  Future<void> _initializePlayer(String filePath) async {
    _videoPlayerController = filePath.startsWith('http')
        ? VideoPlayerController.network(filePath)
        : VideoPlayerController.file(File(filePath));
    
    await _videoPlayerController.initialize();
    
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      aspectRatio: _videoPlayerController.value.aspectRatio,
      placeholder: Container(color: Colors.black),
      autoInitialize: true,
    );

    setState(() {
      _isVideoLoaded = true;
    });
  }

  Future<void> _pickVideoFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      await _initializePlayer(result.files.single.path!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: DragTarget<String>(
        onWillAccept: (data) {
          setState(() {
            _isDragging = true;
          });
          return true;
        },
        onAccept: (data) async {
          setState(() {
            _isDragging = false;
          });
          await _initializePlayer(data);
        },
        onLeave: (data) {
          setState(() {
            _isDragging = false;
          });
        },
        builder: (context, candidateData, rejectedData) {
          if (_isVideoLoaded) {
            return Center(
              child: Chewie(controller: _chewieController),
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _isDragging
                      ? const Icon(
                          Icons.video_library,
                          size: 100,
                          color: Colors.blue,
                        )
                      : IconButton(
                          icon: const Icon(
                            Icons.video_library,
                            size: 100,
                            color: Colors.white,
                          ),
                          onPressed: _pickVideoFile,
                        ),
                  const SizedBox(height: 20),
                  Text(
                    _isDragging ? '松开以播放视频' : '点击选择视频或拖放视频文件到这里',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}