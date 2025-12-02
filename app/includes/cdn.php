<?php
$cdnBase = getenv('CDN_URL');   // returns '' if not set

function asset_url($path) {
    global $cdnBase;
    if ($cdnBase && $cdnBase !== '') {
        // prepend CloudFront domain and strip leading slashes
        return rtrim($cdnBase, '/') . '/' . ltrim($path, '/');
    }
    return $path;
}
?>