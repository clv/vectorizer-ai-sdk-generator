<?php

require_once __DIR__ . '/vendor/autoload.php';

$config = VectorizerAI\Configuration::getDefaultConfiguration()
    ->setUsername(getenv('VECTORIZER_API_ID'))
    ->setPassword(getenv('VECTORIZER_API_SECRET'));

$input = getenv('VECTORIZER_INPUT') ?: 'example.png';
$output = getenv('VECTORIZER_OUTPUT') ?: 'result.svg';

$api = new VectorizerAI\Api\VectorizationApi(null, $config);
$result = $api->postVectorize([
    'image' => new SplFileObject($input),
    'output_file_format' => 'svg',
]);

copy($result->getPathname(), $output);
echo "Wrote $output\n";
