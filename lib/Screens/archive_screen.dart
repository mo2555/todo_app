import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/consts/consts.dart';
import 'package:todo_app/cubit/cubit.dart';

import '../cubit/states.dart';

class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
      builder: (context,states) {
        AppCubit cubit = AppCubit.get(context);
        return cubit.archiveTasks.isNotEmpty?ListView.separated(
            itemBuilder: (ctx, index) => tasksView(index,cubit.archiveTasks,cubit.archiveTasks[index]['id']),
            separatorBuilder: (ctx, index) => Container(
              height: 1,
              color: Colors.grey[300],
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 10),
            ),
            itemCount: cubit.archiveTasks.length):emptyPage;
      },
      listener: (BuildContext context, state) {},
    );
  }
}

