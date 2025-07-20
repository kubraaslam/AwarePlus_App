import 'package:aware_plus/data/infographics_data.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class InfographicsPage extends StatelessWidget {
  final String topic;
  const InfographicsPage({super.key, required this.topic});

  @override
  Widget build(BuildContext context) {
    final files = topicInfographics[topic] ?? [];

    return Scaffold(
      appBar: AppBar(title: Text('$topic Infographics')),
      body: ListView.builder(
        itemCount: files.length,
        itemBuilder: (context, index) {
          final file = files[index];
          if (file.endsWith('.mp4')) {
            return VideoWidget(videoPath: file);
          } else {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(file),
            );
          }
        },
      ),
    );
  }
}

class VideoWidget extends StatefulWidget {
  final String videoPath;
  const VideoWidget({super.key, required this.videoPath});

  @override
  State<VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoPath)
      ..initialize().then((_) {
        setState(() {}); // Refresh when video is ready
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? Column(
            children: [
              AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
              IconButton(
                icon: Icon(
                  _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                ),
                onPressed: () {
                  setState(() {
                    _controller.value.isPlaying ? _controller.pause() : _controller.play();
                  });
                },
              ),
            ],
          )
        : const CircularProgressIndicator();
  }
}