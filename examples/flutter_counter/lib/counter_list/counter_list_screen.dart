import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_counter/counter/cubit/counter_cubit.dart';
import 'package:flutter_counter/counter_list/counter_list_cubit.dart';

class CounterListScreen extends StatelessWidget {
  const CounterListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CounterListCubit(),
      child: CounterListView(),
    );
  }
}

class CounterListView extends StatelessWidget {
  const CounterListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<CounterListCubit, List<CounterCubit>>(
          builder: (context, counterListState) {
        return ListView.separated(
          itemCount: counterListState.length,
          itemBuilder: (context, index) {
            final cubit = counterListState[index];

            return BlocBuilder<CounterCubit, int>(
              bloc: cubit,
              builder: (context, counterState) {
                return Row(
                  children: [
                    Text(counterState.toString()),
                    SizedBox(width: 15),
                    ElevatedButton.icon(
                      onPressed: cubit.increment,
                      icon: Icon(Icons.add),
                      label: Text('add'),
                    ),
                    SizedBox(width: 15),
                    ElevatedButton.icon(
                      onPressed: cubit.decrement,
                      icon: Icon(Icons.remove),
                      label: Text('remove'),
                    ),
                  ],
                );
              },
            );
          },
          separatorBuilder: (_, index) => SizedBox(height: 10),
        );
      }),
    );
  }
}
