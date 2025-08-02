import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:modular_yoga_session_app/providers/session_provider.dart';
import 'package:modular_yoga_session_app/models/yoga_session.dart';

class PoseSessionScreen extends StatefulWidget {
  const PoseSessionScreen({super.key});
  @override
  State<PoseSessionScreen> createState() => _PoseSessionScreenState();
}

class _PoseSessionScreenState extends State<PoseSessionScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<SessionProvider>(context, listen: false)
        .loadSessionFromAsset('assets/poses.json');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionProvider>(
      builder: (context, session, child) {
        if (!session.isInitialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (session.sequence.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('No poses available')),
          );
        }

        if (session.isSessionComplete) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Session Complete!', style: TextStyle(fontSize: 24)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: session.startSession,
                    child: const Text('Restart Session'),
                  ),
                ],
              ),
            ),
          );
        }

        final SequenceItem currentItem = session.currentItem;
        final Metadata? meta = session.metadata;
        final Assets? assets = session.assets;
        final elapsed = session.elapsed;

        ScriptItem? activeScript;
        for (final s in currentItem.script) {
          if (elapsed.inSeconds >= s.startSec && elapsed.inSeconds < s.endSec) {
            activeScript = s;
            break;
          }
        }
        final imagePath = (activeScript != null && assets != null)
            ? 'assets/images/${assets.images[activeScript.imageRef]}'
            : null;

        final itemDuration = Duration(seconds: currentItem.durationSec);
        final progress =
        (elapsed.inMilliseconds / itemDuration.inMilliseconds).clamp(0.0, 1.0);
        final timeLeft =
        (itemDuration - elapsed).inSeconds.clamp(0, itemDuration.inSeconds);

        return Scaffold(
          appBar: AppBar(
            title: Text('${meta?.title ?? ""} – ${currentItem.name}'),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (imagePath != null)
                  Expanded(
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) =>
                      const Center(child: Text('Image not found', style: TextStyle(color: Colors.red))),
                    ),
                  )
                else
                  const SizedBox(
                      height: 200, child: Center(child: Text('No Image'))),
                const SizedBox(height: 18),
                if (activeScript != null)
                  Text(
                    activeScript.text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  )
                else
                  const Text('Get Ready...', style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic)),
                const SizedBox(height: 22),
                LinearProgressIndicator(value: progress, minHeight: 10),
                const SizedBox(height: 8),
                Text('$timeLeft seconds left', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (session.isPlaying && !session.isPaused)
                      ElevatedButton.icon(
                        onPressed: session.pauseSession,
                        icon: const Icon(Icons.pause),
                        label: const Text('Pause'),
                      ),
                    if (session.isPlaying && session.isPaused)
                      ElevatedButton.icon(
                        onPressed: session.resumeSession,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Resume'),
                      ),
                    if (session.isPlaying)
                      const SizedBox(width: 16),
                    if (session.isPlaying)
                      ElevatedButton.icon(
                        onPressed: session.skipPose,
                        icon: const Icon(Icons.skip_next),
                        label: const Text('Skip'),
                      ),
                    if (!session.isPlaying)
                      ElevatedButton(
                        onPressed: session.startSession,
                        child: const Text('Start Session'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
