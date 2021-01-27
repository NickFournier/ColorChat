import 'package:async_redux/async_redux.dart';
import 'package:colorchat/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'appstate.dart';
import 'database.dart';

Store<AppState> store;
final persistor = MyPersistor();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await persistor.initPersistore();
  var initialState = await persistor.initState();
  store = Store<AppState>(
    initialState: initialState,
    persistor: persistor,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => StoreProvider<AppState>(
        store: store,
        child: MaterialApp(
          title: 'Color Chat',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: ColorHomePageConnector(),
        ),
      );
}

class ColorHomePageConnector extends StatelessWidget {
  ColorHomePageConnector({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ViewModel>(
      vm: () => Factory(this),
      builder: (BuildContext context, ViewModel vm) => ColorHomePage(
        changeColor: vm.changeColor,
        setText: vm.setText,
        selectedText: vm.selectedText,
        coloredText: vm.coloredText,
        favorites: vm.favorites,
        selectedColor: vm.selectedColor,
        combination: vm.combination,
        addFavorite: vm.addFavorite,
        removeFavorite: vm.removeFavorite,
      ),
    );
  }
}

class Factory extends VmFactory<AppState, ColorHomePageConnector> {
  Factory(widget) : super(widget);

  @override
  ViewModel fromStore() => ViewModel(
        selectedText: state.text,
        coloredText: state.coloredText,
        favorites: state.favorites,
        selectedColor: state.color,
        changeColor: (String color) => dispatch(SetColorAction(color: color)),
        setText: (String text) => dispatch(SetTextAction(text: text)),
        combination: (String text, String color) =>
            dispatch(CombinationAction(text: text, color: color)),
        addFavorite: (String favorite) =>
            dispatch(AddFavoriteAction(favorite: favorite)),
        removeFavorite: (String favorite) =>
            dispatch(RemoveFavoriteAction(favorite: favorite)),
      );
}

class ViewModel extends Vm {
  final String selectedText;
  final String coloredText;
  final List<dynamic> favorites;
  final String selectedColor;
  final Function changeColor;
  final Function setText;
  final Function combination;
  final Function addFavorite;
  final Function removeFavorite;

  ViewModel({
    @required this.selectedText,
    @required this.coloredText,
    @required this.favorites,
    @required this.selectedColor,
    @required this.changeColor,
    @required this.setText,
    @required this.combination,
    @required this.addFavorite,
    @required this.removeFavorite,
  }) : super(equals: [selectedText, coloredText, favorites, selectedColor]);
}

class ColorHomePage extends StatelessWidget {
  final String selectedText;
  final String coloredText;
  final controller = TextEditingController();
  final List<dynamic> favorites;
  final String selectedColor;
  final Function changeColor;
  final Function setText;
  final Function combination;
  final Function addFavorite;
  final Function removeFavorite;
  Color pickerColor = Color.fromRGBO(0, 0, 0, 1);

  ColorHomePage({
    Key key,
    this.selectedText,
    this.coloredText,
    this.favorites,
    this.selectedColor,
    this.changeColor,
    this.setText,
    this.combination,
    this.addFavorite,
    this.removeFavorite,
  }) : super(key: key);

  void changeColor2(Color color) {
    pickerColor = color;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Color Chat"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Selected color\nClick to change"),
                Text("Favorite Colors\nClick to select\nDrag to scroll"),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => new AlertDialog(
                        content: SingleChildScrollView(
                          child: ColorPicker(
                            pickerColor: HexColor.fromHex(selectedColor),
                            onColorChanged: changeColor2,
                            showLabel: true,
                            pickerAreaHeightPercent: 0.8,
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Got it'),
                            onPressed: () {
                              changeColor(pickerColor.toHex());
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    height: 90.0,
                    width: 90.0,
                    color: HexColor.fromHex(selectedColor),
                  ),
                ),
                SizedBox(
                  height: 110,
                  width: 300,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: false,
                    padding: const EdgeInsets.all(8),
                    itemCount: favorites.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () => {
                          changeColor(favorites[index]),
                          changeColor2(HexColor.fromHex(favorites[index]))
                        },
                        child: Container(
                          width: 90,
                          color: HexColor.fromHex(favorites[index]),
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return SizedBox(
                        width: 10,
                      );
                    },
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    addFavorite(selectedColor);
                  },
                  child: Row(
                    children: [
                      Text("Add Favorite   "),
                      Icon(Icons.add_circle_rounded),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    removeFavorite(selectedColor);
                  },
                  child: Row(
                    children: [
                      Text("Remove Favorite   "),
                      Icon(Icons.remove_circle_rounded),
                    ],
                  ),
                ),
              ],
            ),
            TextField(
              controller: this.controller,
              decoration: new InputDecoration(labelText: "Please enter text"),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    combination(controller.text, selectedColor);
                  },
                  child: Row(
                    children: [
                      Text("Use Color   "),
                      Icon(Icons.format_paint),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    combination(controller.text, "rainbow");
                  },
                  child: Row(
                    children: [
                      Text("RAINBOW!!!   "),
                      Icon(Icons.auto_awesome),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
