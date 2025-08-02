
class YogaSession{
  final Metadata metadata;
  final Assets assets;
  final List<SequenceItem> sequence;
  YogaSession({required this.metadata,required this.assets,required this.sequence});

  factory YogaSession.fromJson(Map<String,dynamic> json){
    final metadata = Metadata.fromJson(json['metadata']);
    final assets = Assets.fromJson(json['assets']);
    final sequence = (json['sequence'] as List).map((e) => SequenceItem.fromJson(e)).toList();
    return YogaSession(metadata: metadata, assets: assets, sequence: sequence);

  }
}
class Metadata {
  final String id;
  final String title;
  final String category;
  final int defaultLoopCount;
  final String tempo;

  Metadata({
    required this.id,
    required this.title,
    required this.category,
    required this.defaultLoopCount,
    required this.tempo,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) {
    return Metadata(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      defaultLoopCount: json['defaultLoopCount'],
      tempo: json['tempo'],
    );
  }
}
class Assets {
  final Map<String, String> images;
  final Map<String, String> audio;

  Assets({required this.images, required this.audio});

  factory Assets.fromJson(Map<String, dynamic> json) {
    return Assets(
      images: Map<String, String>.from(json['images']),
      audio: Map<String, String>.from(json['audio']),
    );
  }
}
class SequenceItem {
  final String type; // 'segment' or 'loop'
  final String name;
  final String audioRef;
  final int durationSec;
  final dynamic iterations; // int or "{{loopCount}}", nullable
  final bool loopable;
  final List<ScriptItem> script;

  SequenceItem({
    required this.type,
    required this.name,
    required this.audioRef,
    required this.durationSec,
    this.iterations,
    this.loopable = false,
    required this.script,
  });

  factory SequenceItem.fromJson(Map<String, dynamic> json) {
    return SequenceItem(
      type: json['type'],
      name: json['name'],
      audioRef: json['audioRef'],
      durationSec: json['durationSec'],
      iterations: json['iterations'],
      loopable: json['loopable'] ?? false,
      script: (json['script'] as List)
          .map((e) => ScriptItem.fromJson(e))
          .toList(),
    );
  }
}
class ScriptItem {
  final String text;
  final int startSec;
  final int endSec;
  final String imageRef;

  ScriptItem({
    required this.text,
    required this.startSec,
    required this.endSec,
    required this.imageRef,
  });

  factory ScriptItem.fromJson(Map<String, dynamic> json) {
    return ScriptItem(
      text: json['text'],
      startSec: json['startSec'],
      endSec: json['endSec'],
      imageRef: json['imageRef'],
    );
  }
}