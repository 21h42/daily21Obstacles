<?php

// use at URL/in.php
// generate new entries to database, instead of phone text messages

function getRandomCharString($length, $lower = true, $upper = true, $nums = true, $special = false)
{
    $pool_lower = 'abcdefghijklmopqrstuvwxyz';
    $pool_upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    $pool_nums = '0123456789             ';
    $pool_special = '!$%^&*+#~/';
   
    $pool = '';
    $res = '';
   
    if ($lower === true) {
        $pool .= $pool_lower;
    }
    if ($upper === true) {
        $pool .= $pool_upper;
    }
    if ($nums === true) {
        $pool .= $pool_nums;
    }
    if ($special === true) {
        $pool .= $pool_special;
    }
   
    if (($length < 0) || ($length == 0)) {
        return $res;
    }
   
    srand((double) microtime() * 1000000);
   
    for ($i = 0; $i < $length; $i++) {
        $charidx = rand() % strlen($pool);
        $char = substr($pool, $charidx, 1);
        $res .= $char;
    }
   
    return $res;
}



$message = getRandomCharString(rand(5,15), true, true, true, false);
$from = 'php script';

$host = '************';
$username = '************';
$db = '************';
$password = '************';

$conn = mysql_connect($host, $username, $password)
or die('Could not connect: ' . mysql_error());

mysql_select_db($db, $conn)
or die("Could not select database because ".mysql_error());

$insert = mysql_query("INSERT INTO inputtable SET message='$message', user='$from'", $conn)
or die("Could not insert data:  ".mysql_error());

mysql_close($conn);

?>