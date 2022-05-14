import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/cubit/states.dart';

import '../Screens/archive_screen.dart';
import '../Screens/done_screen.dart';
import '../Screens/tasks_screen.dart';

class AppCubit extends Cubit<AppStates>{
  AppCubit():super(AppInitialState());

  static AppCubit get(context)=>BlocProvider.of(context);

  List screens = [
    {
      'title': 'New Tasks',
      'screen': const TasksScreen(),
    },
    {
      'title': 'Done Tasks',
      'screen': const DoneScreen(),
    },
    {
      'title': 'Archive Tasks',
      'screen': const ArchiveScreen(),
    },
  ];

  int currentIndex = 0;

  late Database database;

  List<Map> tasks = [];

  List<Map> newTasks = [];

  List<Map> doneTasks = [];

  List<Map> archiveTasks = [];

  bool isBottomSheetShown = false;

  void changeIndex(int index){
    currentIndex = index;
    emit(AppChangeBottomNavBarState());
  }

  void createDatabase() {
    openDatabase('tasks.db', version: 1,
        onCreate: (database, version) {
          database
              .execute(
              'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT)')
              .then((value) => print('Create'))
              .catchError((onError) => print(onError.toString()));
        }, onOpen: (database) {
          getDataFromDataBase(database).then((value) {
            tasks = value;
            newTasks = [];
            doneTasks = [];
            archiveTasks = [];
            tasks.forEach((element) {
              if(element['status']=='new'){
                newTasks.add(element);
              }else if(element['status']=='done') {
                doneTasks.add(element);
              }else {
                archiveTasks.add(element);
              }
            });
            emit(AppGetDataFromDatabaseState());
          });
        }).then((value) {
          database =value;
          emit(AppCreateDatabaseState());
          print('created');
        });
  }

  Future insertDatabase({
    required String title,
    required String time,
    required String date,
  }) async {
    emit(AppInsertDatabaseLoadingState());
    await database.transaction((txn) async {
      txn
          .rawInsert(
          'INSERT INTO tasks(title, date, time , status) VALUES("$title","$date","$time","new")')
          .then((value) {
            print('$value');
            emit(AppInsertDatabaseState());
            getDataFromDataBase(database).then((value) {
              tasks = value;
              newTasks = [];
              doneTasks = [];
              archiveTasks = [];
              tasks.forEach((element) {
                if(element['status']=='new'){
                  newTasks.add(element);
                }else if(element['status']=='done') {
                  doneTasks.add(element);
                }else {
                  archiveTasks.add(element);
                }
              });
              emit(AppGetDataFromDatabaseState());
            });
          })
          .catchError((onError) => print(onError.toString()));
      return null;
    });
    return database;
  }

  Future getDataFromDataBase(database) async {
    List tasks = await database.rawQuery('SELECT * FROM tasks');
    print(tasks);
    return tasks;
  }

  void changeBottomSheetState(bool isShown){
    isBottomSheetShown = isShown;
    emit(AppChangeBottomSheetState());
  }

  void upDataDatabase(String status,int id){

    database.rawUpdate('UPDATE tasks SET status = ? WHERE id = ?',
          [status, id]).then((value) {
      getDataFromDataBase(database).then((value) {
        tasks = value;
        newTasks = [];
        doneTasks = [];
        archiveTasks = [];
        tasks.forEach((element) {
          if(element['status']=='new'){
            newTasks.add(element);
          }else if(element['status']=='done') {
            doneTasks.add(element);
          }else {
            archiveTasks.add(element);
          }
        });
        emit(AppGetDataFromDatabaseState());
      });
      emit(AppUpDataDatabaseState());
    });

  }

  void deleteDatabase(int id){
    database.rawDelete('DELETE FROM tasks WHERE id = ?', [id]).then((value) {
      getDataFromDataBase(database).then((value) {
        tasks = value;
        newTasks = [];
        doneTasks = [];
        archiveTasks = [];
        tasks.forEach((element) {
          if(element['status']=='new'){
            newTasks.add(element);
          }else if(element['status']=='done') {
            doneTasks.add(element);
          }else {
            archiveTasks.add(element);
          }
        });
        emit(AppGetDataFromDatabaseState());
      });
      emit(AppDeleteDatabaseState());
    });
  }

}