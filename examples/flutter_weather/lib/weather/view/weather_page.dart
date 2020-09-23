import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_weather/search/search.dart';
import 'package:flutter_weather/theme/theme.dart';
import 'package:flutter_weather/weather/weather.dart';
import 'package:weather_repository/weather_repository.dart';

class WeatherPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WeatherCubit(
        context.repository<WeatherRepository>(),
      ),
      child: WeatherView(),
    );
  }
}

class WeatherView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Weather')),
      body: Center(
        child: BlocConsumer<WeatherCubit, WeatherState>(
          listener: (context, state) {
            if (state is WeatherLoadSuccess) {
              context.bloc<ThemeCubit>().updateTheme(state.weather);
            }
          },
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
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.search),
        onPressed: () async {
          final city = await Navigator.of(context).push(SearchPage.route());
          await context.bloc<WeatherCubit>().fetchWeather(city);
        },
      ),
    );
  }
}
