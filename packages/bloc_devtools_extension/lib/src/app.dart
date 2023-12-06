import 'package:bloc_devtools_extension/src/home/home.dart';
import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:flutter/widgets.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const DevToolsExtension(
      child: HomePage(),
    );
  }
}
