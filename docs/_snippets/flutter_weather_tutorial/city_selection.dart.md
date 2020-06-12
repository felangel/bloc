```dart
import 'package:flutter/material.dart';

class CitySelection extends StatefulWidget {
  @override
  State<CitySelection> createState() => _CitySelectionState();
}

class _CitySelectionState extends State<CitySelection> {
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('City'),
      ),
      body: Form(
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: TextFormField(
                  controller: _textController,
                  decoration: InputDecoration(
                    labelText: 'City',
                    hintText: 'Chicago',
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                Navigator.pop(context, _textController.text);
              },
            )
          ],
        ),
      ),
    );
  }
}
```
