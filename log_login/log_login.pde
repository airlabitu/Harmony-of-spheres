String path = ""; //"../../../../";

String [] previousLogs = loadStrings(path+"log.txt");
String [] logText = {"login at: " + day()+"/"+month()+"/"+year()+":"+hour()+":"+minute()+":"+second()};
if (previousLogs != null) saveStrings(path+"log.txt", append(previousLogs, logText[0]));
else saveStrings(path+"log.txt", logText);
exit();
