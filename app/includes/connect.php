<?php 
$host = getenv('DB_HOST') ?: 'db';  // 'db' MySQL container name in docker-compose
$user = getenv('DB_USER') ?: 'root';
$pass = getenv('DB_PASSWORD') ?: '';
$db   = getenv('DB_NAME') ?: 'ecommerce_1';

$con = new mysqli($host, $user, $pass, $db);

if(!$con){
    die(mysqli_error($con));
}




?>
