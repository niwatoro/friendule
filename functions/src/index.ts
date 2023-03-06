import { DocumentSnapshot } from "firebase-admin/firestore";
import { getMessaging, TopicMessage } from "firebase-admin/messaging";
import * as functions from "firebase-functions";

const admin = require("firebase-admin");
admin.initializeApp({
  credential: admin.credential.applicationDefault(),
});

exports.sendTopicNotification = functions.firestore.document("notifications/{recevierId}/{notificationId}").onCreate((snap: DocumentSnapshot, context: functions.EventContext) => {
  const data = snap.data()!;
  const message: TopicMessage = {
    android: {
      notification: {
        title: data.title,
        body: data.body,
      },
    },
    apns: {
      payload: {
        aps: {
          alert: {
            title: data.title,
            body: data.body,
          },
          sound: "default",
        },
      },
    },
    topic: data.recevierId,
  };
  return getMessaging().send(message);
});
