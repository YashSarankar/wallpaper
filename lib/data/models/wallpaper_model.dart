import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

@HiveType(typeId: 0)
class WallpaperModel extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String type; // 'static' or 'animated'
  @HiveField(2)
  final String url; // Treats as 'original'
  @HiveField(3)
  final String category;
  @HiveField(4)
  final String? midUrl;
  @HiveField(5)
  final String? lowUrl;
  @HiveField(6)
  final String? highUrl;

  @HiveField(7)
  final String? videoUrl;

  @HiveField(8)
  final String? blurHash;

  const WallpaperModel({
    required this.id,
    required this.type,
    required this.url,
    required this.category,
    this.midUrl,
    this.lowUrl,
    this.highUrl,
    this.videoUrl,
    this.blurHash,
  });

  factory WallpaperModel.fromJson(
    Map<String, dynamic> json,
    String categoryName,
  ) {
    // Backend returns imageUrl: { original, high, mid, low }
    String original = '';
    String? high;
    String? mid;
    String? low;

    if (json['imageUrl'] != null && json['imageUrl'] is Map) {
      original = json['imageUrl']['original'] ?? '';
      high = json['imageUrl']['high'];
      mid = json['imageUrl']['mid'];
      low = json['imageUrl']['low'];
    } else {
      original = json['url'] ?? '';
    }

    // Fallback for ID if mongodb _id is present but id is not
    String id =
        json['id'] ??
        json['_id'] ??
        DateTime.now().millisecondsSinceEpoch.toString();

    return WallpaperModel(
      id: id,
      type: json['type'] ?? 'static',
      url: original,
      category: json['category'] ?? categoryName,
      highUrl: high,
      midUrl: mid,
      lowUrl: low,
      videoUrl: json['videoUrl'],
      blurHash: json['imageUrl'] is Map ? json['imageUrl']['blurHash'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'url': url,
      'category': category,
      'highUrl': highUrl,
      'midUrl': midUrl,
      'lowUrl': lowUrl,
      'videoUrl': videoUrl,
      'blurHash': blurHash,
    };
  }

  WallpaperModel copyWith({
    String? id,
    String? type,
    String? url,
    String? category,
    String? highUrl,
    String? midUrl,
    String? lowUrl,
    String? videoUrl,
    String? blurHash,
  }) {
    return WallpaperModel(
      id: id ?? this.id,
      type: type ?? this.type,
      url: url ?? this.url,
      category: category ?? this.category,
      highUrl: highUrl ?? this.highUrl,
      midUrl: midUrl ?? this.midUrl,
      lowUrl: lowUrl ?? this.lowUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      blurHash: blurHash ?? this.blurHash,
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    url,
    category,
    highUrl,
    midUrl,
    lowUrl,
    videoUrl,
    blurHash,
  ];
}

class WallpaperModelAdapter extends TypeAdapter<WallpaperModel> {
  @override
  final int typeId = 0;

  @override
  WallpaperModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WallpaperModel(
      id: fields[0] as String,
      type: fields[1] as String,
      url: fields[2] as String,
      category: fields[3] as String,
      midUrl: fields[4] as String?,
      lowUrl: fields[5] as String?,
      highUrl: fields[6] as String?,
      videoUrl: fields[7] as String?,
      blurHash: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, WallpaperModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.url)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.midUrl)
      ..writeByte(5)
      ..write(obj.lowUrl)
      ..writeByte(6)
      ..write(obj.highUrl)
      ..writeByte(7)
      ..write(obj.videoUrl)
      ..writeByte(8)
      ..write(obj.blurHash);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WallpaperModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CategoryModel extends Equatable {
  final String name;
  final List<WallpaperModel> wallpapers;

  const CategoryModel({required this.name, required this.wallpapers});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String;
    final wallpapersList = json['wallpapers'] as List;
    final wallpapers = wallpapersList
        .map((e) => WallpaperModel.fromJson(e, name))
        .toList();

    return CategoryModel(name: name, wallpapers: wallpapers);
  }

  @override
  List<Object?> get props => [name, wallpapers];
}
