<?php

// access at : URL/pull.php?pass=***
// check password to make sure no-one else can trigger pulling of messages

$phppass = $_GET['pass']; 

if($phppass=='***') {
	
	$host = '************';
	$username = '*********';
	$db = '*********';
	$password = '*********';

	$conn = mysql_connect($host, $username, $password)
	or die('Could not connect: ' . mysql_error());

	mysql_select_db($db, $conn)
	or die("Could not select database because ".mysql_error());

	// get all entries that have not been displayed yet
	$result = mysql_query("SELECT user, message, timestamp, displayed FROM inputtable WHERE displayed='0' ORDER BY timestamp DESC", $conn)
	or die("Could not get data:  ".mysql_error());
			
	// print out entries
	while($entry = mysql_fetch_array($result)) {
		$date = date($entry[timestamp]);
		// $dateF = $date.format("dddd, mmmm dS, yyyy, h:MM:ss TT");
		print "|$entry[message]";
		print "|$entry[user]";
		print "|$date";
		print "|$entry[displayed]";
	 }


	 // set pulled entries to displayed=0, so they only get pulled once
	$update = mysql_query("UPDATE tropoinput SET displayed='1' WHERE displayed='0'")
	or die("could not update:   ".mysql_error());

	mysql_close($conn);

} else {
	die('Wrong Password.');
}

?>