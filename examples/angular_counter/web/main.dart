import 'package:angular/angular.dart';
import 'package:bloc/bloc.dart';
import 'package:angular_counter/app_component.template.dart' as ng;

class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onTransition(Transition transition) {
    print(transition.toString());
  }
}

void main() {
  BlocSupervisor().delegate = SimpleBlocDelegate();
  runApp(ng.AppComponentNgFactory);
}
