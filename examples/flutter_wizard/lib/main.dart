import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_wizard/bloc/profile_wizard_bloc.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(home: Home());
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
                if (!mounted) return;
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
  const ProfileWizard({super.key});

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
    super.key,
    required this.onComplete,
  });

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
  const ProfileNameForm({super.key});

  static Page<void> page() {
    return const MaterialPage<void>(child: ProfileNameForm());
  }

  @override
  State<ProfileNameForm> createState() => _ProfileNameFormState();
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
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'John Doe',
              ),
            ),
            ElevatedButton(
              onPressed: _name.isNotEmpty
                  ? () => context
                      .read<ProfileWizardBloc>()
                      .add(ProfileWizardNameSubmitted(_name))
                  : null,
              child: const Text('Continue'),
            )
          ],
        ),
      ),
    );
  }
}

class ProfileAgeForm extends StatefulWidget {
  const ProfileAgeForm({super.key});

  static Page<void> page() => const MaterialPage<void>(child: ProfileAgeForm());

  @override
  State<ProfileAgeForm> createState() => _ProfileAgeFormState();
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
              decoration: const InputDecoration(
                labelText: 'Age',
                hintText: '42',
              ),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: _age != null
                  ? () => context
                      .read<ProfileWizardBloc>()
                      .add(ProfileWizardAgeSubmitted(_age))
                  : null,
              child: const Text('Continue'),
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
