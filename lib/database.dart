import 'package:async_redux/async_redux.dart';
import 'package:colorchat/models.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

AppState loadFromDatabase() {
  return AppState.initial();
}

class MyPersistor extends Persistor {
  Database _db;
  StoreRef _store;
  MyPersistor();

  Future<void> initPersistore() async {
    final dir = await getApplicationDocumentsDirectory();
    await dir.create(recursive: true);
    final dbPath = join(dir.path, 'my_database.db');
    _db = await databaseFactoryIo.openDatabase(dbPath);
    _store = intMapStoreFactory.store("app_store");
  }

  Future<AppState> initState() async {
    var initialState = await readState();

    if (initialState == null) {
      initialState = AppState.initial();
      await _store.record(1).put(_db, initialState.toMap());
    }

    return initialState;
  }

  @override
  Future<void> deleteState() async {
    await _store.record(1).delete(_db);
  }

  @override
  Future<void> persistDifference(
      {lastPersistedState: AppState, newState: AppState}) async {
    if (((lastPersistedState) != newState)) {
      await _store.record(1).update(_db, newState.toMap());
    }
  }

  @override
  Future<AppState> readState() async {
    var test = await _store.record(1).get(_db);
    return AppState.fromMap(1, test);
  }
}
