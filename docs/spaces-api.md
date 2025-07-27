# Spaces API Documentation

## Overview

The Spaces API allows users to manage their property listings for dog hosting. Users can create, read, update, and delete their own spaces through authenticated endpoints.

## Authentication

All endpoints require JWT token authentication. Include the token in the Authorization header:

```
Authorization: Bearer <jwt_token>
```

## Base URL

```
/spaces
```

## Endpoints

### GET /spaces

Returns a list of spaces owned by the authenticated user.

**Authentication:** Required

**Response:**
- **200 OK:** Array of space objects
- **401 Unauthorized:** Invalid or missing token

**Example Response:**
```json
[
  {
    "id": 1,
    "user_id": 1,
    "title": "Spacious Backyard Dog Park",
    "description": "Large fenced backyard perfect for medium to large dogs",
    "address1": "123 Main St",
    "address2": null,
    "city": "San Francisco",
    "state": "CA",
    "zipcode": "94102",
    "fenced": "fully",
    "size_sqft": 2500,
    "other_dogs_visible": false,
    "other_pets_visible": false,
    "other_people_visible": true,
    "status": "active",
    "price_per_dog_per_hour": 15.00,
    "created_at": "2025-01-27T12:00:00.000Z",
    "updated_at": "2025-01-27T12:00:00.000Z"
  }
]
```

### GET /spaces/:id

Returns a specific space owned by the authenticated user.

**Authentication:** Required

**Parameters:**
- `id` (integer) - Space ID

**Response:**
- **200 OK:** Space object
- **401 Unauthorized:** Invalid or missing token
- **404 Not Found:** Space not found or not owned by user

**Example Response:**
```json
{
  "id": 1,
  "user_id": 1,
  "title": "Spacious Backyard Dog Park",
  "description": "Large fenced backyard perfect for medium to large dogs",
  "address1": "123 Main St",
  "address2": null,
  "city": "San Francisco",
  "state": "CA",
  "zipcode": "94102",
  "fenced": "fully",
  "size_sqft": 2500,
  "other_dogs_visible": false,
  "other_pets_visible": false,
  "other_people_visible": true,
  "status": "active",
  "price_per_dog_per_hour": 15.00,
  "created_at": "2025-01-27T12:00:00.000Z",
  "updated_at": "2025-01-27T12:00:00.000Z"
}
```

### POST /spaces

Creates a new space for the authenticated user.

**Authentication:** Required

**Request Body:**
```json
{
  "space": {
    "title": "Spacious Backyard Dog Park",
    "description": "Large fenced backyard perfect for medium to large dogs",
    "address1": "123 Main St",
    "address2": null,
    "city": "San Francisco",
    "state": "CA",
    "zipcode": "94102",
    "fenced": "fully",
    "size_sqft": 2500,
    "other_dogs_visible": false,
    "other_pets_visible": false,
    "other_people_visible": true,
    "status": "active",
    "price_per_dog_per_hour": 15.00
  }
}
```

**Response:**
- **201 Created:** Space object
- **401 Unauthorized:** Invalid or missing token
- **422 Unprocessable Entity:** Validation errors

**Example Success Response:**
```json
{
  "id": 1,
  "user_id": 1,
  "title": "Spacious Backyard Dog Park",
  "description": "Large fenced backyard perfect for medium to large dogs",
  "address1": "123 Main St",
  "address2": null,
  "city": "San Francisco",
  "state": "CA",
  "zipcode": "94102",
  "fenced": "fully",
  "size_sqft": 2500,
  "other_dogs_visible": false,
  "other_pets_visible": false,
  "other_people_visible": true,
  "status": "active",
  "price_per_dog_per_hour": 15.00,
  "created_at": "2025-01-27T12:00:00.000Z",
  "updated_at": "2025-01-27T12:00:00.000Z"
}
```

**Example Error Response:**
```json
{
  "errors": [
    "Title can't be blank",
    "Price per dog per hour must be greater than 0"
  ]
}
```

### PUT /spaces/:id

Updates a specific space owned by the authenticated user.

**Authentication:** Required

**Parameters:**
- `id` (integer) - Space ID

**Request Body:**
```json
{
  "space": {
    "title": "Updated Space Title",
    "price_per_dog_per_hour": 20.00
  }
}
```

**Response:**
- **200 OK:** Updated space object
- **401 Unauthorized:** Invalid or missing token
- **404 Not Found:** Space not found or not owned by user
- **422 Unprocessable Entity:** Validation errors

### DELETE /spaces/:id

Deletes a specific space owned by the authenticated user.

**Authentication:** Required

**Parameters:**
- `id` (integer) - Space ID

**Response:**
- **204 No Content:** Space successfully deleted
- **401 Unauthorized:** Invalid or missing token
- **404 Not Found:** Space not found or not owned by user

## Data Fields

### Space Object

| Field | Type | Required | Description | Constraints |
|-------|------|----------|-------------|-------------|
| `id` | integer | - | Unique identifier | Auto-generated |
| `user_id` | integer | - | Owner's user ID | Auto-assigned |
| `title` | string | Yes | Space title | 1-100 characters |
| `description` | text | No | Space description | Up to 1000 characters |
| `address1` | string | Yes | Primary address | 1-255 characters |
| `address2` | string | No | Secondary address | Up to 255 characters |
| `city` | string | Yes | City | 1-100 characters |
| `state` | string | Yes | State/Province | 2 characters |
| `zipcode` | string | Yes | Postal code | 5-10 characters |
| `fenced` | enum | Yes | Fencing status | "fully", "partially", "not_fenced" |
| `size_sqft` | integer | Yes | Size in square feet | > 0 |
| `other_dogs_visible` | boolean | Yes | Other dogs visible/audible | true/false |
| `other_pets_visible` | boolean | Yes | Other pets visible/audible | true/false |
| `other_people_visible` | boolean | Yes | Other people visible/audible | true/false |
| `status` | enum | Yes | Space status | "active", "inactive" |
| `price_per_dog_per_hour` | decimal | Yes | Hourly rate per dog | > 0, up to 2 decimal places |
| `created_at` | datetime | - | Creation timestamp | Auto-generated |
| `updated_at` | datetime | - | Last update timestamp | Auto-generated |

## Validation Rules

### Required Fields
- `title`
- `address1`
- `city`
- `state`
- `zipcode`
- `fenced`
- `size_sqft`
- `other_dogs_visible`
- `other_pets_visible`
- `other_people_visible`
- `status`
- `price_per_dog_per_hour`

### Field Constraints
- `title`: 1-100 characters
- `description`: Up to 1000 characters
- `address1`: 1-255 characters
- `address2`: Up to 255 characters
- `city`: 1-100 characters
- `state`: Exactly 2 characters
- `zipcode`: 5-10 characters, alphanumeric with optional hyphens
- `size_sqft`: Positive integer
- `price_per_dog_per_hour`: Positive decimal with up to 2 decimal places

### Enum Values
- `fenced`: "fully", "partially", "not_fenced"
- `status`: "active", "inactive"

## Error Handling

### HTTP Status Codes
- `200 OK`: Successful GET/PUT request
- `201 Created`: Successful POST request
- `204 No Content`: Successful DELETE request
- `401 Unauthorized`: Missing or invalid authentication token
- `404 Not Found`: Resource not found or access denied
- `422 Unprocessable Entity`: Validation errors

### Error Response Format
```json
{
  "errors": [
    "Error message 1",
    "Error message 2"
  ]
}
```

## Usage Examples

### Creating a Space with cURL

```bash
curl -X POST http://localhost:3000/spaces \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <your_jwt_token>" \
  -d '{
    "space": {
      "title": "Cozy Dog Garden",
      "description": "Small but comfortable space for small to medium dogs",
      "address1": "456 Oak Ave",
      "city": "Oakland",
      "state": "CA",
      "zipcode": "94610",
      "fenced": "fully",
      "size_sqft": 800,
      "other_dogs_visible": true,
      "other_pets_visible": false,
      "other_people_visible": false,
      "status": "active",
      "price_per_dog_per_hour": 12.50
    }
  }'
```

### Updating a Space with cURL

```bash
curl -X PUT http://localhost:3000/spaces/1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <your_jwt_token>" \
  -d '{
    "space": {
      "price_per_dog_per_hour": 18.00,
      "status": "inactive"
    }
  }'
```

### Fetching User's Spaces with cURL

```bash
curl -X GET http://localhost:3000/spaces \
  -H "Authorization: Bearer <your_jwt_token>"
```

## Rate Limiting

Currently, no rate limiting is implemented. Consider implementing rate limiting for production use.

## Pagination

Currently, the index endpoint returns all spaces for the authenticated user. For users with many spaces, consider implementing pagination in future versions.

## Security Considerations

1. **Authentication**: All endpoints require valid JWT tokens
2. **Authorization**: Users can only access their own spaces
3. **Input Validation**: All input is validated according to the constraints above
4. **SQL Injection**: Protected by Rails parameter binding
5. **XSS**: JSON responses don't execute in browsers

## Future Enhancements

Potential features to consider for future versions:
- Photo upload support
- Search and filtering capabilities
- Public space discovery endpoints
- Booking system integration
- Reviews and ratings
- Geographic search
- Availability calendar
