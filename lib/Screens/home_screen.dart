import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:intl/intl.dart';
import 'package:todo_app/cubit/cubit.dart';
import 'package:todo_app/cubit/states.dart';

import '../consts/consts.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController titleController = TextEditingController();

  TextEditingController timeController = TextEditingController();

  TextEditingController dateController = TextEditingController();

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (context, states) {
          if (states is AppInsertDatabaseState) {
            timeController.clear();
            dateController.clear();
            titleController.clear();
            Navigator.pop(context);
            AppCubit.get(context).changeBottomSheetState(false);
          }
        },
        builder: (context, states) {
          AppCubit cubit = AppCubit.get(context);
          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              title: Text(cubit.screens[cubit.currentIndex]['title']),
            ),
            body: ConditionalBuilder(
              condition: states is! AppInsertDatabaseLoadingState,
              builder: (ctx) => cubit.screens[cubit.currentIndex]['screen'],
              fallback: (ctx) => const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              currentIndex: cubit.currentIndex,
              onTap: (index) {
                cubit.changeIndex(index);
              },
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Tasks'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.check_circle_outline), label: 'Done'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.archive_outlined), label: 'Archive'),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                if (cubit.isBottomSheetShown) {
                  if (formKey.currentState!.validate()) {
                    cubit.insertDatabase(
                      title: titleController.text,
                      time: timeController.text,
                      date: dateController.text,
                    );
                  } else
                    return;
                } else {
                  scaffoldKey.currentState
                      ?.showBottomSheet(
                          (context) => Container(
                                padding: const EdgeInsets.all(20),
                                color: Colors.white,
                                child: Form(
                                  key: formKey,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      defaultFormField(
                                        controller: titleController,
                                        type: TextInputType.text,
                                        validate: (String? value) {
                                          if (value!.isEmpty) {
                                            return 'Title must not be empty';
                                          }
                                          return null;
                                        },
                                        label: const Text('Task Title'),
                                        prefix: const Icon(Icons.title),
                                      ),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      defaultFormField(
                                        controller: timeController,
                                        type: TextInputType.datetime,
                                        validate: (String? value) {
                                          if (value!.isEmpty) {
                                            return 'Time must not be empty';
                                          }
                                          return null;
                                        },
                                        label: const Text('Task Time'),
                                        prefix: const Icon(
                                            Icons.watch_later_outlined),
                                        onTap: () {
                                          showTimePicker(
                                                  context: context,
                                                  initialTime: TimeOfDay.now())
                                              .then((value) => setState(() {
                                                    timeController.text = value!
                                                        .format(context)
                                                        .toString();
                                                  }));
                                        },
                                      ),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      defaultFormField(
                                        controller: dateController,
                                        type: TextInputType.datetime,
                                        validate: (String? value) {
                                          if (value!.isEmpty) {
                                            return 'Date must not be empty';
                                          }
                                          return null;
                                        },
                                        label: const Text('Task Date'),
                                        prefix:
                                            const Icon(Icons.calendar_today),
                                        onTap: () {
                                          showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime.now(),
                                            lastDate: DateTime.now().add(
                                              const Duration(days: 30),
                                            ),
                                          ).then((value) => setState(() {
                                                dateController.text =
                                                    DateFormat.yMMMd()
                                                        .format(value!)
                                                        .toString();
                                              }));
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          elevation: 20)
                      .closed
                      .then((value) {
                    cubit.changeBottomSheetState(false);
                  });
                  cubit.changeBottomSheetState(true);
                }
              },
              child: cubit.isBottomSheetShown
                  ? const Icon(Icons.add)
                  : const Icon(Icons.edit),
            ),
          );
        },
      ),
    );
  }
}