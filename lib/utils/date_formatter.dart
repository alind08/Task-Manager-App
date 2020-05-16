import 'package:intl/intl.dart';

String dateFormatted(){
  var now = DateTime.now();

  var formatter = new DateFormat.yMd().add_jm();

  String formatted = formatter.format(now);

  return formatted;
}