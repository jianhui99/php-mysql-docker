<?php

ini_set("display_errors",0);
ini_set("log_errors",1);
ini_set("error_log",dirname(__FILE__).'/error_log2.log');

$db_name = getenv('MYSQL_DATABASE') ?: 'hy_db';
$mysql_username = "root";
$mysql_password = "123456";
$server_name = getenv('MYSQL_HOST') ?: 'hy-mysql';

// check request method
$request_method = $_SERVER['REQUEST_METHOD'];
$mode = isset($_GET['mode']) ? $_GET['mode'] : '';


/**
 * Get database connection
 * 
 * @param string $server_name
 * @param string $username
 * @param string $password
 * @param string $dbname
 * @return mysqli|null
 */
function getDbConnection($server_name, $username, $password, $dbname) {
    try {
        $conn = new mysqli($server_name, $username, $password, $dbname);
        if ($conn->connect_error) {
            throw new Exception("Connection failed: " . $conn->connect_error);
        }
        return $conn;
    } catch (Exception $e) {
        error_log($e->getMessage(), 0);
        return null;
    }
}


/**
 * Records an audit trail entry in the database.
 * 
 * @param string $action   The action being performed (e.g., 'add', 'edit', 'delete').
 * @param string $module   The module in which the action occurred (e.g., 'item', 'stockin', 'basket').
 * @param int    $ref      A reference ID for the action, usually the primary key of the related record.
 * @param string $detail   Detailed description of the action or changes.
 * @param string $operator The username or identifier of the person performing the action.
 * 
 * @return bool
 */
function recordAuditTrail($action, $module, $ref, $detail, $operator) {
    $conn = getDbConnection();
    
    $sql = "INSERT INTO audit_trail (action, module, ref, detail, operator, date)
            VALUES (?, ?, ?, ?, ?, NOW())";
    
    if ($stmt = $conn->prepare($sql)) {
        $stmt->bind_param("ssiss", $action, $module, $ref, $detail, $operator);

        if ($stmt->execute()) {
            $stmt->close();
            return true;
        } else {
            error_log("Error executing audit trail SQL: " . $stmt->error);
        }

        $stmt->close();
    } else {
        error_log("Error preparing audit trail SQL: " . $conn->error);
    }

    $conn->close();
    
    return false;
}

switch ($request_method) {
    case 'GET':
        switch($mode) {
            default:
                http_response_code(404);
                echo json_encode(['success' => 0, 'message' => '404 page not found']);
            break; 
        }
    break;

    case 'POST':
        switch($mode) {
            case 'register-warehouseUser':
                $response = array();
                $response['success'] = 0 ;

                $inputData = json_decode(file_get_contents('php://input'), true);
                $username = $inputData['username'] ?? '';
                $password = $inputData['password'] ?? '';
                $name = $inputData['name'] ?? '';
                $shortcode = $inputData['shortcode'] ?? '';
                $email = $inputData['email'] ?? '';
                $contact_no = $inputData['contact_no'] ?? '';
                $image = $inputData['image'] ?? '';

                // the following input is not nullable (required)
                if (empty($name) || empty($shortcode) || empty($password)) {
                    $response['message'] = "Fields 'name', 'shortcode', and 'password' cannot be empty.";
                    echo json_encode($response);
                    exit;
                }

                try {
                    $conn = getDbConnection($server_name, $mysql_username, $mysql_password, $db_name);
                    if (!$conn) {
                        echo json_encode(["success" => 0, "message" => "Database connection error."]);
                        exit;
                    }

                    // check user exits
                    $stmt_check = $conn->prepare("SELECT user_id FROM user WHERE name = ?");
                    $stmt_check->bind_param("s", $name);
                    $stmt_check->execute();
                    $result_check = $stmt_check->get_result();

                    if ($result_check->num_rows > 0) {
                        $response['message'] = "The user already exists.";
                        echo json_encode($response);
                        $stmt_check->close();
                        $conn->close();
                        exit;
                    }

                    $stmt_check->close();
                    
                    $sql = "INSERT INTO user (username, password, name, shortcode, email, contact_no, image) VALUES (?, ?, ?, ?, ?, ?, ?)";
                    $stmt = $conn->prepare($sql);
                    $stmt->bind_param("sssssss", $username, $password, $name, $shortcode, $email, $contact_no, $image);

                    if ($stmt->execute()) {
                        $response['success'] = 1;
                    } else {
                        $response['success'] = 0;
                    }
                } catch (Exception $e) {
                    $response['message'] = $e->getMessage();
                    echo json_encode($response);
                    error_log($e->getMessage(), 0);
                } finally {
                    $stmt->close();
                    $conn->close();
                }

                echo json_encode($response);
            break;

            case 'login-warehouseUser':
                $response = array();
                $response['success'] = 0;
        
   
                $inputData = json_decode(file_get_contents('php://input'), true);
                $username = $inputData['username'] ?? null;
                $password = $inputData['password'] ?? null;
        
                if (empty($username) || empty($password)) {
                    $response['message'] = "Username and password cannot be empty.";
                    echo json_encode($response);
                    exit;
                }
        
                try {
                    $conn = getDbConnection($server_name, $mysql_username, $mysql_password, $db_name);
        
                    $stmt = $conn->prepare("SELECT user_id, name, shortcode, email, contact_no, image, status FROM user WHERE username = ? AND password = BINARY ? AND status = 'active'");
                    $stmt->bind_param("ss", $username, $password);
        
                    if ($stmt->execute()) {
                        $result = $stmt->get_result();
                        if ($result->num_rows > 0) {
                            $response['success'] = 1;
                            $response['data'] = array();
        
                            while ($row = $result->fetch_assoc()) {
                                unset($row['username'], $row['password'], $row['created'], $row['modified']);
                                $response['data'][] = $row;
                            }
        
                            // $response['message'] = "Login successful.";
                        } else {
                            $response['message'] = "Invalid credentials or inactive user.";
                        }
                    } else {
                        $response['message'] = "Error executing query.";
                    }
        
                    $stmt->close();
                    $conn->close();
                } catch (Exception $e) {
                    $response['message'] = "Database connection error: " . $e->getMessage();
                }

                echo json_encode($response);
            break;

            default:
                http_response_code(404);
                echo json_encode(['success' => 0, 'message' => '404 page not found']);
            break;
        }
    break;

    default:
        http_response_code(405);
        echo json_encode(['success' => 0, 'message' => 'Method Not Allowed']);
        break;  

}
?>