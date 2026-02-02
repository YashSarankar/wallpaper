import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

@HiveType(typeId: 0)
class WallpaperModel extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String type; // 'static' or 'animated'
  @HiveField(2)
  final String url;
  @HiveField(3)
  final String category;

  const WallpaperModel({
    required this.id,
    required this.type,
    required this.url,
    required this.category,
  });

  factory WallpaperModel.fromJson(
    Map<String, dynamic> json,
    String categoryName,
  ) {
    return WallpaperModel(
      id: json['id'] as String,
      type: json['type'] as String,
      url: json['url'] as String,
      category: categoryName,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'type': type, 'url': url, 'category': category};
  }

  WallpaperModel copyWith({
    String? id,
    String? type,
    String? url,
    String? category,
  }) {
    return WallpaperModel(
      id: id ?? this.id,
      type: type ?? this.type,
      url: url ?? this.url,
      category: category ?? this.category,
    );
  }

  @override
  List<Object?> get props => [id, type, url, category];
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
    );
  }

  @override
  void write(BinaryWriter writer, WallpaperModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.url)
      ..writeByte(3)
      ..write(obj.category);
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
