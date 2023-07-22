import { hasDependency } from "./has-dependency";



export async function getBlocImportPath(): Promise<string> {
    if (await hasDependency('flutter_bloc')) {
        return `import 'package:flutter_bloc/flutter_bloc.dart';`;
    }
    return `import 'package:bloc/bloc.dart';`;

}
