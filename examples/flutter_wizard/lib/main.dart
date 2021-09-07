import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_wizard/bloc/profile_wizard_bloc.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const MaterialApp(home: Home());
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                final profile = await Navigator.of(context).push(
                  ProfileWizard.route(),
                );
                ScaffoldMessenger.of(context)
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
  const ProfileWizard({Key? key}) : super(key: key);

  static Route<Profile> route() {
    return MaterialPageRoute(builder: (_) => const ProfileWizard());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileWizardBloc(),
      child: ProfileWizardFlow(
        onComplete: (profile) => Navigator.of(context).pop(profile),
      ),
    );
  }
}

class ProfileWizardFlow extends StatelessWidget {
  const ProfileWizardFlow({
    Key? key,
    required this.onComplete,
  }) : super(key: key);

  final ValueSetter<Profile> onComplete;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileWizardBloc, ProfileWizardState>(
      listenWhen: (_, state) => state.profile.isComplete,
      listener: (context, state) => onComplete(state.profile),
      child: FlowBuilder<ProfileWizardState>(
        state: context.watch<ProfileWizardBloc>().state,
        onGeneratePages: (state, pages) {
          return [
            ProfileNameForm.page(),
            if (state.profile.name != null) ProfileAgeForm.page(),
          ];
        },
      ),
    );
  }
}

class ProfileNameForm extends StatefulWidget {
  const ProfileNameForm({Key? key}) : super(key: key);

  static Page page() => const MaterialPage(child: ProfileNameForm());

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
            ElevatedButton(
              child: const Text('Continue'),
              onPressed: _name.isNotEmpty
                  ? () => context
                      .read<ProfileWizardBloc>()
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
  const ProfileAgeForm({Key? key}) : super(key: key);

  static Page page() => const MaterialPage(child: ProfileAgeForm());

  @override
  _ProfileAgeFormState createState() => _ProfileAgeFormState();
}

class _ProfileAgeFormState extends State<ProfileAgeForm> {
  int? _age;

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
            ElevatedButton(
              child: const Text('Continue'),
              onPressed: _age != null
                  ? () => context
                      .read<ProfileWizardBloc>()
                      .add(ProfileWizardAgeSubmitted(_age))
                  : null,
            )
          ],
        ),
      ),
    );
  }
}

extension on Profile {
  bool get isComplete => name != null && age != null;
}
