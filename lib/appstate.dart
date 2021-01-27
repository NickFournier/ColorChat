import 'dart:developer';

import 'package:async_redux/async_redux.dart';
import 'package:colorchat/models.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class SetColorAction extends ReduxAction<AppState> {
  final String color;

  SetColorAction({@required this.color});

  @override
  AppState reduce() => state.copyWith(
      selectedColor: color, coloredText: colorText(state.text, color));
}

class SetTextAction extends ReduxAction<AppState> {
  final String text;

  SetTextAction({@required this.text});

  @override
  AppState reduce() =>
      state.copyWith(text: text, coloredText: colorText(text, state.color));
}

class AddFavoriteAction extends ReduxAction<AppState> {
  final String favorite;

  AddFavoriteAction({@required this.favorite});

  @override
  AppState reduce() => state.copyWith(
      favorites: state.favorites.any((element) => element == favorite)
          ? state.favorites
          : [...state.favorites, favorite]);
}

class RemoveFavoriteAction extends ReduxAction<AppState> {
  final String favorite;

  RemoveFavoriteAction({@required this.favorite});

  @override
  AppState reduce() => state.copyWith(
      favorites: [...state.favorites.where((element) => element != favorite)]);
}

class CombinationAction extends ReduxAction<AppState> {
  final String text;
  final String color;

  CombinationAction({
    @required this.text,
    @required this.color,
  });

  @override
  Future<Null> reduce() async {
    if (text.isEmpty) {
      log("string is empty");
    }
    dispatch(SetTextAction(text: text));
    await store.waitCondition((state) => state.coloredText.contains(text));
    Clipboard.setData(new ClipboardData(text: "${colorText(text, color)}"));
    return null;
  }
}

String colorText(String text, String color) {
  var output = "";
  if (color == "rainbow") {
    var charList = text.characters.toList();
    for (var i = 0; i < charList.length; i++) {
      output += _colors[i % _colors.length];
      output += charList[i];
    }
  } else {
    return "[$color[000000]][B]$text";
  }
  return output;
}

var _colors = [
  "[2196f3[000000]][B]",
  "[3f51b5[000000]][B]",
  "[673ab7[000000]][B]",
  "[9c27b0[000000]][B]",
  "[e91e63[000000]][B]",
  "[f44336[000000]][B]",
  "[f39c12[000000]][B]",
  "[f1c40f[000000]][B]",
  "[2ecc71[000000]][B]",
  "[27ae60[000000]][B]",
  "[16a085[000000]][B]",
  "[1abc9c[000000]][B]",
  "[d35400[000000]][B]",
  "[e67e22[000000]][B]"
];
