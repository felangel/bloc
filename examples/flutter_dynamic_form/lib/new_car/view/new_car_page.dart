import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dynamic_form/new_car/new_car.dart';
import 'package:flutter_dynamic_form/new_car_repository.dart';

class NewCarPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Dynamic Form')),
      body: BlocProvider(
        create: (_) => NewCarBloc(
          newCarRepository: context.read<NewCarRepository>(),
        )..add(const NewCarFormLoaded()),
        child: NewCarForm(),
      ),
    );
  }
}

class NewCarForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    void _onBrandChanged(String? brand) =>
        context.read<NewCarBloc>().add(NewCarBrandChanged(brand: brand));

    void _onModelChanged(String? model) =>
        context.read<NewCarBloc>().add(NewCarModelChanged(model: model));

    void _onYearChanged(String? year) =>
        context.read<NewCarBloc>().add(NewCarYearChanged(year: year));

    void _onFormSubmitted({String? brand, String? model, String? year}) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Submitted $brand $model $year')),
        );
    }

    return BlocBuilder<NewCarBloc, NewCarState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Material(
              child: DropdownButton<String>(
                key: const Key('newCarForm_brand_dropdownButton'),
                items: state.brands.isNotEmpty
                    ? state.brands.map((brand) {
                        return DropdownMenuItem(
                            value: brand, child: Text(brand));
                      }).toList()
                    : const [],
                value: state.brand,
                hint: const Text('Select a Brand'),
                onChanged: _onBrandChanged,
              ),
            ),
            Material(
              child: DropdownButton<String>(
                key: const Key('newCarForm_model_dropdownButton'),
                items: state.models.isNotEmpty
                    ? state.models.map((model) {
                        return DropdownMenuItem(
                            value: model, child: Text(model));
                      }).toList()
                    : const [],
                value: state.model,
                hint: const Text('Select a Model'),
                onChanged: _onModelChanged,
              ),
            ),
            Material(
              child: DropdownButton<String>(
                key: const Key('newCarForm_year_dropdownButton'),
                items: state.years.isNotEmpty
                    ? state.years.map((year) {
                        return DropdownMenuItem(value: year, child: Text(year));
                      }).toList()
                    : const [],
                value: state.year,
                hint: const Text('Select a Year'),
                onChanged: _onYearChanged,
              ),
            ),
            ElevatedButton(
              onPressed: state.isComplete
                  ? () => _onFormSubmitted(
                        brand: state.brand,
                        model: state.model,
                        year: state.year,
                      )
                  : null,
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}
