<?php

namespace App\Models;

use Exception;
use PDO;

abstract class Model
{
    protected string $table;
    protected PDO $pdo;

    public function __construct(string $table)
    {
        try {
            $this->table = $table;
            $this->pdo = new PDO('mysql:host=mysql;dbname=xdebug_php', 'root', '123456');
            $this->pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        } catch (Exception $e) {
            die("Database connection error: " . $e->getMessage());
        }
    }

    // Create a new record
    public function create(array $data): array
    {
        try {
            $now = date('Y-m-d H:i:s');
            $data["created_at"] = $now;
            $data["updated_at"] = $now;
            $columns = implode(',', array_keys($data));
            $placeholders = implode(',', array_map(fn($v) => ":$v", array_keys($data)));
            $sql = "INSERT INTO $this->table ($columns) VALUES ($placeholders)";
            $stmt = $this->pdo->prepare($sql);

            return [
                "success" => true,
                "data" => $stmt->execute($data)
            ];
        } catch (Exception $e) {
            return [
                "success" => false,
                "message" => $e->getMessage()
            ];
        }
    }

    // Read a record by ID
    public function destroy($id): array
    {
        try {
            $this->find($id);
            $now = date('Y-m-d H:i:s');
            $data["deleted_at"] = $now;
            $data["updated_at"] = $now;
            $setString = implode(',', array_map(fn($key) => "$key = :$key", array_keys($data)));
            $sql = "UPDATE $this->table SET $setString WHERE id = :id";
            $stmt = $this->pdo->prepare($sql);
            $data['id'] = $id;

            return [
                "success" => true,
                "data" => $stmt->execute($data)
            ];
        } catch (Exception $e) {
            return [
                "success" => false,
                "message" => $e->getMessage()
            ];
        }
    }

    // Update a record by ID
    public function show($id): array
    {
        try {
            $this->find($id);
            $stmt = $this->pdo->prepare("SELECT * FROM $this->table WHERE id = :id and deleted_at IS NULL");
            $stmt->execute(['id' => $id]);

            return [
                "success" => true,
                "data" => $stmt->fetch(PDO::FETCH_ASSOC)
            ];
        } catch (Exception $e) {
            return [
                "success" => false,
                "message" => $e->getMessage()
            ];
        }
    }

    // Delete a record by ID
    public function update($id, array $data): array
    {
        try {
            $this->find($id);
            $now = date('Y-m-d H:i:s');
            $data["updated_at"] = $now;
            $setString = implode(',', array_map(fn($key) => "$key = :$key", array_keys($data)));
            $sql = "UPDATE $this->table SET $setString WHERE id = :id";
            $stmt = $this->pdo->prepare($sql);
            $data['id'] = $id;

            return [
                "success" => true,
                "data" => $stmt->execute($data)
            ];
        } catch (Exception $e) {
            return [
                "success" => false,
                "message" => $e->getMessage()
            ];
        }
    }

    // Get all records
    public function all(): array
    {
        try {
            $stmt = $this->pdo->query("SELECT * FROM $this->table WHERE deleted_at IS NULL");

            return [
                "success" => true,
                "data" => $stmt->fetchAll(PDO::FETCH_ASSOC)
            ];
        } catch (Exception $e) {
            return [
                "success" => false,
                "message" => $e->getMessage()
            ];
        }
    }

    /**
     * @throws Exception
     */
    private function find($id)
    {
        $stmt = $this->pdo->prepare("SELECT * FROM $this->table WHERE id = :id and deleted_at IS NULL");
        $stmt->execute(['id' => $id]);

        if ($stmt->rowCount() !== 1) {
            throw new Exception("Record not found");
        }
    }
}
