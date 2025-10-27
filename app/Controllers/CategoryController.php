<?php

namespace App\Controllers;

use App\Models\Category;
use Illuminate\Http\Response;

class CategoryController
{
    public function index(): Response
    {
        $result = new Category()->all();
        return $result["success"]
            ? response($result["data"])
            : response($result["message"], 500);
    }

    public function store(): Response
    {
        $result = new Category()->create(["name" => "test"]);
        return $result["success"]
            ? response($result["data"])
            : response($result["message"], 500);
    }

    public function show($id): Response
    {
        $result = new Category()->show($id);
        return $result["success"]
            ? response($result["data"])
            : response($result["message"], 500);
    }

    public function update(): Response
    {
        $result = new Category()->update(1, ["name" => "test" . rand(0, 100)]);
        return $result["success"]
            ? response($result["data"])
            : response($result["message"], 500);
    }

    public function destroy($id): Response
    {
        $result = new Category()->destroy($id);
        return $result["success"]
            ? response($result["data"])
            : response($result["message"], 500);
    }
}
