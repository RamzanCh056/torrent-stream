import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Torrent Streamer',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TorrentStreamerScreen(),
    );
  }
}

class TorrentStreamerScreen extends StatefulWidget {
  const TorrentStreamerScreen({Key? key}) : super(key: key);

  @override
  _TorrentStreamerScreenState createState() => _TorrentStreamerScreenState();
}

class _TorrentStreamerScreenState extends State<TorrentStreamerScreen> {
  VideoPlayerController? _videoController;
  String status = "Idle";
  String magnetLink = "";

  /// Starts streaming by sending the magnet link to the WebTorrent server.
  Future<void> _startStreaming() async {
    try {
      setState(() => status = "Starting stream...");

      // Sending a POST request to the WebTorrent server
      final response = await http.post(
        Uri.parse('http://localhost:3000/stream'), // Update to your server address
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'magnet': magnetLink}),
      );

      if (response.statusCode == 200) {
        // Parse the stream URL from the server response
        final streamUrl = jsonDecode(response.body)['streamUrl'];
        _initializeVideoPlayer(streamUrl);
        setState(() => status = "Streaming: $streamUrl");
      } else {
        setState(() => status = "Error: ${response.body}");
      }
    } catch (e) {
      setState(() => status = "Error: $e");
    }
  }

  /// Initializes the video player with the provided stream URL.
  void _initializeVideoPlayer(String streamUrl) {
    _videoController?.dispose();
    _videoController = VideoPlayerController.network(streamUrl)
      ..initialize().then((_) {
        setState(() {});
        _videoController?.play();
      });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Torrent Streamer')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onChanged: (value) => magnetLink = value,
              decoration: const InputDecoration(
                labelText: "Enter Magnet Link",
                hintText: "Paste your magnet link here",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _startStreaming,


              child: const Text("Start Live Stream"),
            ),
            const SizedBox(height: 16),
            Text("Status: $status"),
            const SizedBox(height: 16),
            if (_videoController != null && _videoController!.value.isInitialized)
              AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              ),
            if (_videoController == null)
              const Text(
                "Enter a magnet link and click 'Start Live Stream' to begin.",
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
