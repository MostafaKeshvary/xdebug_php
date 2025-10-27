<?php

use Illuminate\Http\Response;

if (!function_exists("response")) {
    /**
     * Creates and returns an instance of the Response class.
     *
     * This function initializes a new response object, allowing for easy creation of
     * HTTP responses with content, status codes, and headers.
     *
     * @param mixed $content The content to be returned in the response.
     * @param int $status The HTTP status code for the response.
     * @param array $headers An array of headers to include in the response.
     * @return Response A new instance of the Response class.
     */
    function response(mixed $content = '', int $status = 200, array $headers = []): Response
    {
        return new Response($content, $status, $headers);
    }
}
