import 'package:flutter/material.dart';
import 'package:flutter_cubit/flutter_cubit.dart';

import 'package:flutter_weather/app/app.dart';
import 'package:flutter_weather/app/weather/weather_cubit.dart';

class WeatherPage extends StatelessWidget {
  const WeatherPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Weather'),
      ),
      body: const Center(child: _WeatherView()),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.search),
        onPressed: () async {
          final city = await Navigator.of(context).push(CitySearch.route());
          await context.cubit<WeatherCubit>().getWeather(city: city);
        },
      ),
    );
  }
}

class _WeatherView extends StatelessWidget {
  const _WeatherView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CubitBuilder<WeatherCubit, WeatherState>(
      builder: (context, state) {
        if (state is WeatherInitial) {
          return const WeatherEmpty();
        } else if (state is WeatherLoadInProgress) {
          return const WeatherLoading();
        } else if (state is WeatherLoadSuccess) {
          return WeatherPopulated(weather: state.weather);
        } else {
          return const WeatherError();
        }
      },
    );
  }
}
