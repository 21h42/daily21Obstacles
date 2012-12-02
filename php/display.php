<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Incoming SMS</title>
<style type="text/css">
<!--
body {
	font-size: 12px;
	font-family: Verdana, Geneva, sans-serif;
}
#sms, #headline {
	clear:both;
}
#headline {
	text-transform: uppercase;
	font-weight: bold;
}
#timestamp, #message, #phone, #displayed {
	float: left;
	width: 150px;
}

-->
</style>
</head>

<body>

<h2>Text Messages</h2>

<?php


// see at URL/display.php

$host = '************';
$username = '*********';
$db = '*********';
$password = '*********';
		
$conn = mysql_connect($host, $username, $password)
	or die('Could not connect: ' . mysql_error());

	mysql_select_db($db, $conn)
or die("Could not select database because ".mysql_error());


// get all entries
$result = mysql_query("SELECT user, message, timestamp, displayed FROM inputtable ORDER BY timestamp DESC", $conn)
	or die("Could not get data:  ".mysql_error());

// print all entries
while($entry = mysql_fetch_array($result)) {
	print "<div id='sms'>";
	$date = date($entry[timestamp]);
	print "<div id='message'>| $entry[message]</div>";
	print "<div id='phone'>| $entry[user]</div>";
	print "<div id='timestamp'>| $date</div>";
	print "<div id='displayed'>| $entry[displayed]</div>";
	print "</div>";
 }

mysql_close($conn);


?>



</body>
</html>
		