importScripts('https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js');

const firebaseConfig = {
    apiKey: "AIzaSyCT-tPPJ34EBnfdByhnmpPybRiWFt9qICc",
    authDomain: "csv-web-notification.firebaseapp.com",
    projectId: "csv-web-notification",
    storageBucket: "csv-web-notification.appspot.com",
    messagingSenderId: "59094487007",
    appId: "1:59094487007:web:611e252785dd9be5243e6a",
    // measurementId: "G-W07G372FDS"
};
  firebase.initializeApp(firebaseConfig);
  
  const messaging = firebase.messaging();

  messaging.onBackgroundMessage((message) => {
    console.log("onBackgroundMessage", message);

    const notificationTitle = message.notification.title;
    const notificationOptions = {
      body: message.notification.body,
    };
    self.registration.showNotification(notificationTitle,
      notificationOptions);
  });