<?php

require_once __DIR__ . "/vendor/autoload.php";

use Illuminate\Http\Response;

$requestUri = $_SERVER['REQUEST_URI'];
$path = parse_url($requestUri, PHP_URL_PATH);

$path = trim($path, '/');

$segments = explode('/', $path);

$controllerName = ucfirst(array_shift($segments)) . 'Controller';
$methodName = !empty($segments) ? array_shift($segments) : 'index';

$controllerFile = __DIR__ . "/src/Controllers/$controllerName.php";

if (file_exists($controllerFile)) {
    $fullClassName = "App\\Controllers\\$controllerName";
    if (class_exists($fullClassName)) {
        $controller = new $fullClassName();

        if (method_exists($controller, $methodName)) {
            $result = call_user_func_array([$controller, $methodName], $segments);

            if ($result instanceof Response) {
                $result->send();
            }
        } else {
            echo "Method '$methodName' not found in '$controllerName'.";
        }
    } else {
        echo "Controller class '$controllerName' not found.";
    }
} else {
    echo "Controller file '$controllerFile' not found.";
}
