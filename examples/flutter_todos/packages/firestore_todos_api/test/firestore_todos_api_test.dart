import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firestore_todos_api/firestore_todos_api.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:todos_api/todos_api.dart';

void main() {
  late FirebaseFirestore fakeFirestore;
  late CollectionReference<Todo> todosCollection;

  group(
    'FirestoreTodosApi',
    () {
      final todos = [
        Todo(
          id: '1',
          title: 'title 1',
          description: 'description 1',
        ),
        Todo(
          id: '2',
          title: 'title 2',
          description: 'description 2',
        ),
        Todo(
          id: '3',
          title: 'title 3',
          description: 'description 3',
        ),
      ];

      setUpAll(
        () {
          fakeFirestore = FakeFirebaseFirestore();

          todosCollection = fakeFirestore.collection('todos').withConverter(
                fromFirestore: (snapshot, _) => Todo.fromJson(snapshot.data()!),
                toFirestore: (todo, _) => todo.toJson(),
              );

          for (final todo in todos) {
            todosCollection.add(todo);
          }
        },
      );

      FirestoreTodosApi createSubject() {
        return FirestoreTodosApi(firestore: fakeFirestore);
      }

      group(
        'constructor',
        () {
          test('can be instantiated', () {
            expect(FirestoreTodosApi(firestore: fakeFirestore), isNotNull);
          });

          group(
            'initializes the todos stream',
            () {
              test(
                'with existing todos if present',
                () {
                  final subject = createSubject();

                  expect(subject.getTodos(), emits(todos));
                },
              );
              test('with empty list if no todos present', () {
                fakeFirestore = FakeFirebaseFirestore();

                final subject = createSubject();

                expect(subject.getTodos(), emits(const <Todo>[]));
              });
            },
          );

          group('saveTodo', () {
            test('saves new todo', () {
              final newTodo = Todo(
                id: '4',
                title: 'title 4',
                description: 'description 4',
              );

              final newTodos = [...todos, newTodo];

              final subject = createSubject();

              expect(subject.saveTodo(newTodo), completes);

              expect(subject.getTodos(), emitsThrough(newTodos));

              // verify(
              //   () => plugin.setString(
              //     LocalStorageTodosApi.kTodosCollectionKey,
              //     json.encode(newTodos),
              //   ),
              // ).called(1);
            });

            test('updates existing todos', () {
              final updatedTodo = Todo(
                id: '1',
                title: 'new title 1',
                description: 'new description 1',
                isCompleted: true,
              );
              final newTodos = [updatedTodo, ...todos.sublist(1)];

              final subject = createSubject();

              expect(subject.saveTodo(updatedTodo), completes);
              expect(subject.getTodos(), emits(newTodos));

              // verify(
              //   () => plugin.setString(
              //     LocalStorageTodosApi.kTodosCollectionKey,
              //     json.encode(newTodos),
              //   ),
              // ).called(1);
            });
          });
        },
      );
    },
  );
}
