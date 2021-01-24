String [] previousLogs = loadStrings("log.txt");
String [] logText = {"Shutdown at: " + day()+"/"+month()+"/"+year()+":"+hour()+":"+minute()+":"+second()};
if (previousLogs != null) saveStrings("log.txt", append(previousLogs, logText[0]));
else saveStrings("log.txt", logText);
exit();
