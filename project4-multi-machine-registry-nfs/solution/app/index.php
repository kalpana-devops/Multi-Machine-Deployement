<?php
require __DIR__ . '/vendor/autoload.php';
use Predis\Client;
$redisHost = getenv('REDIS_HOST') ?: 'redis';
$redisPort = getenv('REDIS_PORT') ?: 6379;
$redis = new Client([
'scheme' => 'tcp',
'host' => $redisHost,
'port' => (int) $redisPort,
]);
try {
$visits = $redis->incr('visit_count');
} catch (Exception $e) {
http_response_code(500);
die('Could not connect to Redis at ' . htmlspecialchars($redisHost . ':' . $redisPort)
. ' — ' . htmlspecialchars($e->getMessage()));
}
// Only set this once — first visit ever recorded
$firstVisitTime = $redis->get('first_visit_time');
if (!$firstVisitTime) {
$firstVisitTime = date('Y-m-d H:i:s');
$redis->set('first_visit_time', $firstVisitTime);
}
$hostname = gethostname();
?>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>PHP + Redis Visit Counter</title>
<style>
body { font-family: sans-serif; max-width: 480px; margin: 80px auto; text-align: center; }
.count { font-size: 48px; color: #2563eb; font-weight: bold; }
.meta { color: #6b7280; font-size: 13px; margin-top: 24px; }
</style>
</head>
<body>
<h1>Visit Counter</h1>
<div class="count"><?= htmlspecialchars((string) $visits) ?></div>
<p>total visits (stored in Redis)</p>
<div class="meta">
<p>Served by container: <code><?= htmlspecialchars($hostname) ?></code></p>
<p>Counter tracking started: <?= htmlspecialchars($firstVisitTime) ?></p>
</div>
</body>
</html>
