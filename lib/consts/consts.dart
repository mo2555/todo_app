import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/cubit/cubit.dart';

import '../cubit/states.dart';

Widget defaultFormField({
  required TextEditingController controller,
  required TextInputType type,
  ValueChanged<String>? onSubmit,
  ValueChanged<String>? onChanged,
  GestureTapCallback? onTap,
  bool isPassword = false,
  required FormFieldValidator<String>? validate,
  required Widget label,
  required Widget prefix,
  Widget? suffix,
  Function? suffixPressed,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: type,
    obscureText: isPassword,
    onFieldSubmitted: onSubmit,
    onTap: onTap,
    onChanged: onChanged,
    validator: validate,
    decoration: InputDecoration(
        label: label,
        prefixIcon: prefix,
        suffix: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        )),
  );
}

Widget tasksView(index,tasks,key) => BlocConsumer<AppCubit, AppStates>(
      listener: (BuildContext context, state) {},
      builder: (BuildContext context, Object? state) {
        var cubit = AppCubit.get(context);
        return Dismissible(
          onDismissed: (v){
            cubit.deleteDatabase(key);
          },
          key: Key('key$key'),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  child: Text(
                    tasks[index]['time'].toString(),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tasks[index]['title'].toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 5,),
                      Text(
                        tasks[index]['date'].toString(),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () {
                          cubit.upDataDatabase('done',key);
                        },
                        icon: const Icon(
                          Icons.check_box_rounded,
                          color: Colors.green,
                          size: 30,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          cubit.upDataDatabase('archive',key);
                        },
                        icon: const Icon(
                          Icons.archive,
                          color: Colors.grey,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

Widget emptyPage = Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: const [
      Icon(Icons.menu,
        size: 100,
        color: Colors.grey,
      ),
      Text('No tasks yet, please add some tasks.',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    ],
  ),
);
