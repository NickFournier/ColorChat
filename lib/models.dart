import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';

class Favorite {
  String color;

  Favorite(String color) {
    this.color = color;
  }
}

var _colors = [
  "2196f3",
  "3f51b5",
  "673ab7",
  "9c27b0",
  "e91e63",
  "f44336",
  "f39c12",
  "f1c40f",
  "2ecc71",
  "27ae60",
  "16a085",
  "1abc9c",
  "d35400",
  "e67e22"
];

class AppState extends Equatable {
  final int id = 1;
  List<dynamic> favorites;
  String text;
  String color;
  String coloredText;

  AppState({
    @required this.text,
    @required this.favorites,
    @required this.color,
    @required this.coloredText,
  });

  factory AppState.initial() {
    return AppState(
      text: "",
      favorites: _colors,
      color: Colors.black.toHex(),
      coloredText: "",
    );
  }

  AppState copyWith({
    String text,
    List<String> favorites,
    String selectedColor,
    String coloredText,
  }) {
    return AppState(
      text: text ?? this.text,
      favorites: favorites ?? this.favorites,
      color: selectedColor ?? this.color,
      coloredText: coloredText ?? this.coloredText,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': this.text,
      'favorites': this.favorites,
      'color': this.color,
      'coloredText': this.coloredText,
    };
  }

  factory AppState.fromMap(int id, Map<String, dynamic> map) {
    if (map == null) {
      return null;
    }
    return AppState(
      text: map['text'],
      favorites: map['favorites'],
      color: map['color'],
      coloredText: map['coloredText'],
    );
  }

  @override
  List<Object> get props => [
        text,
        favorites,
        color,
        coloredText,
      ];
}

extension HexColor on Color {
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}
