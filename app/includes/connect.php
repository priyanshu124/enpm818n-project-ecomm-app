<?php
$host = getenv('DB_HOST') ?: 'db'; 
$user = getenv('DB_USER') ?: 'root';
$pass = getenv('DB_PASSWORD') ?: '';
$db   = getenv('DB_NAME') ?: 'ecommerce_1';
$port = getenv('DB_PORT') ?: 3306;

// Initialize MySQLi
$mysqli = mysqli_init();

// Enable SSL using AWS RDS CA bundle
$ssl_ca = '/etc/ssl/certs/rds-combined-ca-bundle.pem';
$mysqli->ssl_set(null, null, $ssl_ca, null, null);

// Connect to database with SSL
if (!$mysqli->real_connect($host, $user, $pass, $db, $port, null, MYSQLI_CLIENT_SSL)) {
    die("MySQL connection failed: " . $mysqli->connect_error);
}

// Set charset to avoid warnings
$mysqli->set_charset('utf8mb4');

// Assign $mysqli to $con so old code still works
$con = $mysqli;

// echo "Connected to {$db} on {$host} successfully!";
?>
