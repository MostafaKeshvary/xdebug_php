<?php

require_once __DIR__ . "/../vendor/autoload.php";

$requestUri = $_SERVER['REQUEST_URI'];
$path = parse_url($requestUri, PHP_URL_PATH);

$path = trim($path, '/');

$segments = explode('/', $path);

$controllerName = ucfirst(array_shift($segments)) . 'Controller';
$methodName = !empty($segments) ? array_shift($segments) : 'index';

$controllerFile = __DIR__ . "/../app/Controllers/$controllerName.php";

if (!file_exists($controllerFile)) {
    response("Controller file '$controllerFile' not found.", 404);
    return;
}

$fullClassName = "App\\Controllers\\$controllerName";
if (!class_exists($fullClassName)) {
    response("Controller class '$controllerName' not found.", 404);
    return;
}

$controller = new $fullClassName();
if (!method_exists($controller, $methodName)) {
    response("Method '$methodName' not found in '$controllerName'.", 404);
    return;
}

call_user_func_array([$controller, $methodName], $segments);
