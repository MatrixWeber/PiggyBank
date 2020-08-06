import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class Value {
  String key;
  double subject;
  bool completed;
  String userId;
  String moneyArt = "€"; 
  int year = int.parse(DateFormat('EEE d MMM').format(DateTime.now()));
  int day = int.parse(DateFormat('EEE d MMM').format(DateTime.now()));
  int month = int.parse(DateFormat('EEE d MMM').format(DateTime.now()));

  Value(this.subject, this.userId, this.completed);

  Value.fromSnapshot(DataSnapshot snapshot) :
    key = snapshot.key,
    userId = snapshot.value["userId"],
    subject = snapshot.value["subject"],
    completed = snapshot.value["completed"],
    moneyArt = snapshot.value["money_art"],
    year = snapshot.value["year"];
    month = snapshot.value["month"];
    day = snapshot.value["day"];

  toJson() {
    return {
      "userId": userId,
      "subject": subject,
      "completed": completed,
      "money_art": moneyArt,
      "year": year,
      "day": day,
      "month": month,
    };
  }
}