import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../providers/music_provider.dart';

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({super.key});

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  StreamSubscription? _accelSub;
  double _currentTilt = 0.0;

  @override
  void initState() {
    super.initState();

    _accelSub = accelerometerEvents.listen((AccelerometerEvent event) {
      final raw = -event.x;
      final newTilt = (raw * 0.08).clamp(-0.5, 0.5);
      print("SENSOR → raw: $raw | newTilt: $newTilt | currentTilt: $_currentTilt");
      setState(() {
        _currentTilt = newTilt;
      });
    });
  }

  @override
  void dispose() {
    _accelSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("BUILD tilt: $_currentTilt");
    final musicProvider = context.watch<MusicProvider>();
    final track = musicProvider.currentTrack;

    if (track == null) return const SizedBox.shrink();

    return Container(
      height: 80,
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.deepPurple[900],
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            track.image,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(track.artist, maxLines: 1),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TiltIcon(
              tilt: _currentTilt,
              child: IconButton(
                icon: Icon(
                  musicProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                ),
                onPressed: () => musicProvider.playTrack(track),
              ),
            ),
            _TiltIcon(
              tilt: -_currentTilt * 0.6,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => musicProvider.stop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TiltIcon extends StatelessWidget {
  final double tilt;
  final Widget child;

  const _TiltIcon({required this.tilt, required this.child});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: tilt,
      child: child,
    );
  }
}