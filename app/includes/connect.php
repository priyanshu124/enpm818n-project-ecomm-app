<?php 
$host = getenv('DB_HOST') ?: 'db';  // 'db' MySQL container name in docker-compose
$user = getenv('DB_USER') ?: 'root';
$pass = getenv('DB_PASSWORD') ?: '';
$db   = getenv('DB_NAME') ?: 'ecommerce_1';
$port = getenv('DB_PORT') ?: 3306;

// Initialize MySQLi
$mysqli = mysqli_init();

// Enable SSL using AWS RDS CA bundle
$ssl_ca = '/opt/rds-ca/global-bundle.pem';
$mysqli->ssl_set(null, null, $ssl_ca, null, null);

// Connect to database with SSL
$connected = $mysqli->real_connect(
    $host,
    $user,
    $pass,
    $db,
    $port,
    null,
    MYSQLI_CLIENT_SSL
);

$con = new mysqli($host, $user, $pass, $db);

if(!$con){
    die(mysqli_error($con));
}

echo "Connected to database successfully!";


?>
