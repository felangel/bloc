```dart
class BusinessLogicComponent extends Bloc<MyEvent, MyState> {
    BusinessLogicComponent(this.repository) {
        on<AppStarted>((event, emit) {
            try {
                final data = await repository.getAllDataThatMeetsRequirements();
                emit(Success(data));
            } catch (error) {
                emit(Failure(error));
            }
        });
    }

    final Repository repository;
}
```
