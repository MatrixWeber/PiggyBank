import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class Value {
  String key;
  double subject;
  bool completed;
  String userId;
  String moneyArt = "€";
  String formattedDate = DateFormat('EEE d MMM').format(new DateTime.now());

  Value(this.subject, this.userId, this.completed);

  Value.fromSnapshot(DataSnapshot snapshot) :
    key = snapshot.key,
    userId = snapshot.value["userId"],
    subject = snapshot.value["subject"],
    completed = snapshot.value["completed"],
    moneyArt = snapshot.value["money_art"],
    formattedDate = snapshot.value["date"];

  toJson() {
    return {
      "userId": userId,
      "subject": subject,
      "completed": completed,
      "money_art": moneyArt,
      "date": formattedDate,
    };
  }
}