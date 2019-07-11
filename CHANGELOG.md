# 0.3.0

- Update `HydratedBlocStorage` to use `getTemporaryDirectory` instead of `getApplicationDocumentsDirectory`
- Documentation Updates

# 0.2.1

- Bugfix to handle `Blocs` alongside `HydrateBlocs` within the same application.
- `toJson` can return `null` to avoid persisting the state change

# 0.2.0

- Upated `HydrateBlocDelegate` to have a static `build`
- Updated `toJson` and `fromJson` to eliminate the need to call `json.encode` and `json.decode` explicitly.
- `HydratedBlocSharedPreferences` replaced with `HydratedBlocStorage`
- Removed dependency on `SharedPreferences`
- Documentation Updates

# 0.1.0

- Renamed `HydratedBlocSharedPreferences` to `HydratedSharedPreferences`
- Documentation Updates

# 0.0.3

Added `clear` to `HydratedBlocStorage` API and Documentation Updates

# 0.0.2

Documentation Updates

# 0.0.1

Initial Version of the library.

Includes:

- `HydratedBloc`
- `HydratedBlocDelegate`
- `HydratedBlocSharedPreferences`
