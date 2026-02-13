# User Management API Documentation

## Base URL
`http://localhost:8000/api/auth/`

## Endpoints

### 1. Login
**POST** `/api/auth/login/`

**Request:**
```json
{
  "username": "chw1",
  "password": "chw123"
}
```

**Response:**
```json
{
  "access": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "user": {
    "id": 2,
    "username": "chw1",
    "full_name": "Daniel Chol",
    "phone": "+211924778090",
    "state": "Jonglei",
    "facility": "Bor State Hospital",
    "role": "CHW"
  }
}
```

### 2. Get Current User
**GET** `/api/auth/me/`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response:**
```json
{
  "id": 2,
  "username": "chw1",
  "email": "",
  "first_name": "Daniel",
  "last_name": "Chol",
  "phone": "+211924778090",
  "state": "Jonglei",
  "facility": "Bor State Hospital",
  "role": "CHW",
  "is_active_chw": true,
  "created_at": "2026-02-10T10:30:00Z"
}
```

### 3. List CHW Users (MoH Admin only)
**GET** `/api/auth/chw-users/`

**Headers:**
```
Authorization: Bearer <admin_access_token>
```

**Response:**
```json
[
  {
    "id": 2,
    "username": "chw1",
    "email": "",
    "first_name": "Daniel",
    "last_name": "Chol",
    "phone": "+211924778090",
    "state": "Jonglei",
    "facility": "Bor State Hospital",
    "role": "CHW",
    "is_active_chw": true,
    "created_at": "2026-02-10T10:30:00Z"
  }
]
```

### 4. Create CHW User (MoH Admin only)
**POST** `/api/auth/chw-users/`

**Headers:**
```
Authorization: Bearer <admin_access_token>
```

**Request:**
```json
{
  "username": "chw3",
  "password": "chw123",
  "first_name": "John",
  "last_name": "Deng",
  "phone": "+211987654321",
  "state": "Unity",
  "facility": "Bentiu Hospital",
  "role": "CHW",
  "email": "john.deng@example.com"
}
```

### 5. Update CHW User (MoH Admin only)
**PUT/PATCH** `/api/auth/chw-users/{id}/`

**Headers:**
```
Authorization: Bearer <admin_access_token>
```

**Request:**
```json
{
  "phone": "+211999888777",
  "facility": "New Facility Name"
}
```

### 6. Delete CHW User (MoH Admin only)
**DELETE** `/api/auth/chw-users/{id}/`

**Headers:**
```
Authorization: Bearer <admin_access_token>
```

### 7. Reset Password (MoH Admin only)
**POST** `/api/auth/chw-users/{id}/reset_password/`

**Headers:**
```
Authorization: Bearer <admin_access_token>
```

**Request:**
```json
{
  "password": "newpassword123"
}
```

## Test Credentials

### MoH Administrator
- Username: `admin`
- Password: `admin123`
- Role: `MOH_ADMIN`

### CHW Users
- Username: `chw1` / Password: `chw123` (Daniel Chol - Bor State Hospital, Jonglei)
- Username: `chw2` / Password: `chw123` (Mary Akech - Juba Teaching Hospital, Central Equatoria)

## Testing with curl

### Login
```bash
curl -X POST http://localhost:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"username":"chw1","password":"chw123"}'
```

### Get Current User
```bash
curl -X GET http://localhost:8000/api/auth/me/ \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### Create New CHW (as admin)
```bash
curl -X POST http://localhost:8000/api/auth/chw-users/ \
  -H "Authorization: Bearer ADMIN_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "username":"chw3",
    "password":"chw123",
    "first_name":"John",
    "last_name":"Deng",
    "phone":"+211987654321",
    "state":"Unity",
    "facility":"Bentiu Hospital",
    "role":"CHW"
  }'
```
