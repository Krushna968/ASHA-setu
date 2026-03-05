import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../theme/app_theme.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String title;

  const VideoPlayerScreen({super.key, required this.videoUrl, required this.title});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    
    // Robust parsing of ID
    String? videoId = YoutubePlayerController.convertUrlToId(widget.videoUrl);
    
    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoId ?? '',
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        strictRelatedVideos: true,
        mute: false,
        enableCaption: true,
        enableJavaScript: true,
        origin: 'https://www.youtube.com',
      ),
    );
  }

  @override
  void dispose() {
    // Note: Don't call _controller.close() if using YoutubePlayerScaffold as it handles it,
    // but in some versions it's good practice. For iframe v5+ we just ignore.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerScaffold(
      controller: _controller,
      aspectRatio: 16 / 9,
      builder: (context, player) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, color: MyTheme.textDark)),
            backgroundColor: Colors.white,
            iconTheme: const IconThemeData(color: MyTheme.textDark),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Column(
            children: [
              // The Player
              player,
              
              // Video Info
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: MyTheme.primaryBlue.withAlpha(30),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'TRAINING VIDEO',
                                style: TextStyle(
                                  color: MyTheme.primaryBlue,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.share_outlined, color: Colors.grey, size: 20),
                            const SizedBox(width: 16),
                            const Icon(Icons.bookmark_border_rounded, color: Colors.grey, size: 20),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: MyTheme.textDark,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'ASHA Training Academy • 2026',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        const Divider(height: 40),
                        const Text(
                          'About this lesson',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: MyTheme.textDark),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'This module provides critical instruction on health best practices for ASHA workers. Please watch the entire video to ensure you can provide the highest quality care to your community.',
                          style: TextStyle(fontSize: 15, color: MyTheme.textLight, height: 1.6),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F4FF),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: MyTheme.primaryBlue.withAlpha(40)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.lightbulb_outline_rounded, color: MyTheme.primaryBlue),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'Pro Tip: You can retake the quiz after watching if you feel unsure.',
                                  style: TextStyle(color: MyTheme.primaryBlue.withAlpha(200), fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
