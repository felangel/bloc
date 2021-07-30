if (typeof firebase === "undefined")
  throw new Error(
    "hosting/init-error: Firebase SDK not detected. You must include it before /__/firebase/init.js"
  );
firebase.initializeApp({
  apiKey: "AIzaSyCRMZ2m3W6_kq6DaLAXJHjWTh6DnQepRQU",
  appId: "1:979633879366:web:1b77b4e28b5ffe2fd98d47",
  authDomain: "flutter-firebase-auth-2b1c3.firebaseapp.com",
  databaseURL: "https://flutter-firebase-auth-2b1c3.firebaseio.com",
  messagingSenderId: "979633879366",
  projectId: "flutter-firebase-auth-2b1c3",
  storageBucket: "flutter-firebase-auth-2b1c3.appspot.com",
});
