
# flutter_notifications
An example flutter app, built with 'flutter_bloc' to implement Push Notifications feature, using Firebase Cloud Message service (FCM). 

## Setup 
- Firstly make sure to create a [new Firebase Project](https://console.firebase.google.com/u/0/) 
- Follow all initialization steps for firebase [here](https://firebase.flutter.dev/docs/overview)
- Follow all initialization steps for Firebase Cloud Messaging [here](https://firebase.flutter.dev/docs/messaging/overview)

## Code Explanation
- ### `NotificationRepository` 
    - This is an abstract class, the `NotificationBloc` will be dependent on it and will listen to a stream of notifications.
    - code: 
        ```
            abstract class NotificationRepository {
                Future<void> initialize();
                Stream<NotificationEntity> get notificationStream;
                void dispose(); 
            }
        ```
- ### `NotificationRepositoryFCM`
    - This is the contrete implementation of the `NotificationRepository`. 
    - it handles showing notification, and emiting a notification stream for the Bloc to consume.
    - Also has a top level function, which handles receiving notification, when the app is not running, but this function can't add notification to the notification stream, bcz it runs outside of the context of the app, and can't perform UI impacting logic.

- ### `NotificationBloc` 
    ##### events: 
    ```
        class NotificationReceived extends NotificationEvent {
                NotificationReceived(this.notificationEntity);
                final NotificationEntity notificationEntity;
                @override
                List<Object> get props => [notificationEntity];
            }
    ```
    ##### states
    ```
        class NotificationInitial extends NotificationState {}
       
        class NotificationRecieveSuccess extends NotificationState{
            NotificationRecieveSuccess(this.notificationModel);
            final NotificationModel notificationModel;
            @override
            List<Object> get props => [notificationModel];
        }
    ```
    - will have dependency on `NotificationRepository`.
    - listens to `notificationStream` and adds `NotificationReceived` event. 
    - emits `NotificationRecieveSuccess` state, in response to the `NotificationReceived` event. 

## Features
- Push notification visible when the app is in foreground and background

## Issues 
- When the user taps on a notification, the app launches, and opens the home scree, instead it should take the user directly to the notification scree.

## Desired Freatures
- ### List of Recent Notifications:
   - Currently the NotificationRepository only emits a one notification at a time, that is the most recent one. In order to emit a list of recent notifications, we need to save them when they arrive, when the app is in backgroudn or terminated state. 
   - Notifications that arrive in background or terminated state are handled by [`onBackgroundMessage`](https://pub.dev/documentation/firebase_messaging/latest/firebase_messaging/FirebaseMessaging/onBackgroundMessage.html), we have to pass a [`BackgroundMessageHandler`](https://pub.dev/documentation/firebase_messaging_platform_interface/latest/firebase_messaging_platform_interface/BackgroundMessageHandler.html) to this method. 
   - this `BackgroundMessageHandler` is a top level function and runs outside of application context. So, we cannot do any UI impacting logic in it, that is, we cannot add notification that this Handler recieves, to the notification stream that the `NotificationBloc` listens to. But we can save notifications to local storage in this handler. 
   - When the app starts, it should get this list of recent notification from local storage.
   - The question is, what is the best way to do it ?

- ### Show unread notifications
   - Distinguish between which notifications user has already read and which are not

- ### Interaction Handling
    - when a user taps on a notification, the app should launch and open a specific page (Notifications Page) and not the Home page of the app, right now it only opens the Home page. This can be done with the help of BlocListener, and Navigation, but I am unable to do it.