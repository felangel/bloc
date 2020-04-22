import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_wizard/bloc/profile_wizard_bloc.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Builder(
          builder: (context) {
            return RaisedButton(
              onPressed: () async {
                final profile = await Navigator.of(context).push(
                  ProfileWizard.route(),
                );
                Scaffold.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text('$profile')));
              },
              child: const Text('Start Profile Wizard'),
            );
          },
        ),
      ),
    );
  }
}

class ProfileWizard extends StatelessWidget {
  static Route<Profile> route() {
    return MaterialPageRoute(builder: (_) => ProfileWizard());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileWizardBloc(),
      child: ProfileWizardController(
        onComplete: (profile) => Navigator.of(context).pop(profile),
      ),
    );
  }
}

class ProfileWizardController extends StatefulWidget {
  const ProfileWizardController({Key key, @required this.onComplete})
      : super(key: key);

  final ValueSetter<Profile> onComplete;

  @override
  _ProfileWizardControllerState createState() =>
      _ProfileWizardControllerState();
}

class _ProfileWizardControllerState extends State<ProfileWizardController> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  NavigatorState get _navigator => _navigatorKey.currentState;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileWizardBloc, ProfileWizardState>(
      listener: (context, state) async {
        if (state.profile.age != null) {
          widget.onComplete(state.profile);
        } else if (state.profile.name?.isNotEmpty == true) {
          _navigator.push(ProfileAgeForm.route());
        }
      },
      child: Navigator(
        key: _navigatorKey,
        onGenerateRoute: (_) => ProfileNameForm.route(),
      ),
    );
  }
}

class ProfileNameForm extends StatefulWidget {
  static Route route() {
    return MaterialPageRoute(builder: (_) => ProfileNameForm());
  }

  @override
  _ProfileNameFormState createState() => _ProfileNameFormState();
}

class _ProfileNameFormState extends State<ProfileNameForm> {
  var _name = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Name')),
      body: Center(
        child: Column(
          children: <Widget>[
            TextField(
              onChanged: (value) => setState(() => _name = value),
              decoration: InputDecoration(
                labelText: 'Name',
                hintText: 'John Doe',
              ),
            ),
            RaisedButton(
              child: const Text('Continue'),
              onPressed: _name.isNotEmpty
                  ? () => context
                      .bloc<ProfileWizardBloc>()
                      .add(ProfileWizardNameSubmitted(_name))
                  : null,
            )
          ],
        ),
      ),
    );
  }
}

class ProfileAgeForm extends StatefulWidget {
  static Route route() {
    return MaterialPageRoute(builder: (_) => ProfileAgeForm());
  }

  @override
  _ProfileAgeFormState createState() => _ProfileAgeFormState();
}

class _ProfileAgeFormState extends State<ProfileAgeForm> {
  int _age;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Age')),
      body: Center(
        child: Column(
          children: <Widget>[
            TextField(
              onChanged: (value) => setState(() => _age = int.parse(value)),
              decoration: InputDecoration(
                labelText: 'Age',
                hintText: '42',
              ),
              keyboardType: TextInputType.number,
            ),
            RaisedButton(
              child: const Text('Continue'),
              onPressed: _age != null
                  ? () => context
                      .bloc<ProfileWizardBloc>()
                      .add(ProfileWizardAgeSubmitted(_age))
                  : null,
            )
          ],
        ),
      ),
    );
  }
}
