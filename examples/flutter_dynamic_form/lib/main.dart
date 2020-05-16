import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dynamic_form/bloc/new_car_bloc.dart';
import 'package:flutter_dynamic_form/new_car_repository.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter Dynamic Form'),
        ),
        body: BlocProvider(
          create: (context) => NewCarBloc(
            newCarRepository: NewCarRepository(),
          )..add(NewCarFormLoaded()),
          child: MyForm(),
        ),
      ),
    );
  }
}

class MyForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    void _onBrandChanged(String brand) => BlocProvider.of<NewCarBloc>(context)
        .add(NewCarBrandChanged(brand: brand));

    void _onModelChanged(String model) => BlocProvider.of<NewCarBloc>(context)
        .add(NewCarModelChanged(model: model));

    void _onYearChanged(String year) =>
        BlocProvider.of<NewCarBloc>(context).add(NewCarYearChanged(year: year));

    void _onFormSubmitted({
      String brand,
      String model,
      String year,
    }) =>
        Scaffold.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('Submitted $brand $model $year'),
            ),
          );

    return BlocBuilder<NewCarBloc, NewCarState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            DropdownButton<String>(
              items: state.brands?.isNotEmpty == true
                  ? state.brands
                      .map((String brand) =>
                          DropdownMenuItem(value: brand, child: Text(brand)))
                      .toList()
                  : const [],
              value: state.brand,
              hint: Text('Select a Brand'),
              onChanged: _onBrandChanged,
            ),
            DropdownButton<String>(
              items: state.models?.isNotEmpty == true
                  ? state.models
                      .map((String model) =>
                          DropdownMenuItem(value: model, child: Text(model)))
                      .toList()
                  : const [],
              value: state.model,
              hint: Text('Select a Model'),
              onChanged: _onModelChanged,
            ),
            DropdownButton<String>(
              items: state.years?.isNotEmpty == true
                  ? state.years
                      .map((String year) =>
                          DropdownMenuItem(value: year, child: Text(year)))
                      .toList()
                  : const [],
              value: state.year,
              hint: Text('Select a Year'),
              onChanged: _onYearChanged,
            ),
            RaisedButton(
              onPressed: state.isComplete
                  ? () => _onFormSubmitted(
                        brand: state.brand,
                        model: state.model,
                        year: state.year,
                      )
                  : null,
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}
