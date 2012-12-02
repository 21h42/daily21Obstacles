<?php

// used by tropo
// at URL/phoneinput.php
// users send text messages to: *** *** ****
// messages are saved to database

$jsonData = file_get_contents('php://input');
$jsonInput = json_decode($jsonData,true);

$message = $jsonInput["session"]["initialText"];
$from = $jsonInput["session"]["from"]["id"];

$host = '************';
$username = '*********';
$db = '*********';
$password = '*********';

$conn = mysql_connect($host, $username, $password)
or die('Could not connect: ' . mysql_error());

mysql_select_db($db, $conn)
or die("Could not select database because ".mysql_error());

$insert = mysql_query("INSERT INTO inputtable SET message='$message', user='$from'", $conn)
or die("Could not insert data:  ".mysql_error());

mysql_close($conn);

?>