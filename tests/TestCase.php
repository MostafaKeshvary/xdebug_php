<?php

namespace Tests;

use Illuminate\Http\Request;
use Illuminate\Http\Response;
use PHPUnit\Framework\TestCase as BaseTestCase;

abstract class TestCase extends BaseTestCase
{
    protected function makeRequest(string $method, string $uri, array $data = [])
    {
        return Request::create($uri, strtoupper($method), $data);
    }

    protected function assertResponseOk(Response $response): void
    {
        $this->assertEquals(200, $response->getStatusCode());
    }
}
