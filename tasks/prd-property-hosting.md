# PRD: Property Hosting (Spaces) - Host Experience

## Introduction

We are building a property hosting feature that allows users to monetize their private spaces by listing them as rentable dog spaces. This creates an Airbnb-like marketplace for dog owners who need safe, private areas for their pets. In the application, these properties will be referred to as "spaces" to maintain brand consistency and avoid confusion with existing terminology.

This phase focuses exclusively on the host experience - enabling property owners to create and manage their space listings through the API. The renter/booking functionality will be addressed in future phases.

### Context and Background
- WagMap is expanding from a simple pet location service to a comprehensive marketplace
- Dog owners often struggle to find safe, private, and affordable spaces for their pets
- Property owners have underutilized spaces that could generate income
- This feature creates a two-sided marketplace connecting space owners with dog owners

### Problem Statement
Property owners currently have no way to list their private spaces for rent to dog owners, missing out on potential income opportunities while dog owners lack access to private, safe spaces for their pets.

## Goals

### Primary Objectives
- Enable users to list their private properties as rentable dog spaces
- Create a comprehensive data model that captures all necessary space information
- Establish the foundation for a future booking and payment system
- Build the core API endpoints for space management

### Business Value
- New revenue stream through commission on future bookings
- Increased user engagement and retention
- Expansion of platform utility beyond basic pet services
- Creation of a unique value proposition in the pet services market

### User Value
- Hosts can generate income from underutilized spaces
- Hosts can build community connections with fellow pet owners
- Simple, straightforward process to list spaces
- Full control over space details and pricing

## User Stories

### Host User Stories
- As a property owner, I want to create a space listing so that I can rent out my private area to dog owners
- As a host, I want to specify my space's address so that renters know the exact location
- As a host, I want to describe my space's fencing status so that renters know if their dogs will be secure
- As a host, I want to upload photos of my space so that renters can see what they're booking
- As a host, I want to set my pricing per dog per hour so that I can control my income
- As a host, I want to specify occupancy limits so that my space doesn't get overcrowded
- As a host, I want to describe the size of my space so that renters know if it fits their needs
- As a host, I want to indicate what's visible/audible from my property so that renters understand the environment
- As a host, I want to activate/deactivate my listing so that I can control availability
- As a host, I want to edit my space details so that I can keep information current
- As a host, I want to view my space listings so that I can manage my properties

## Functional Requirements

### Core Features

#### Space Model
The Space model must capture:
- **Address Information**:
  - address1 (required, string, max 255 chars)
  - address2 (optional, string, max 255 chars) 
  - city (required, string, max 100 chars)
  - state (required, string, 2 chars)
  - zipcode (required, string, 10 chars)
- **Property Details**:
  - fencing_status (required, enum: 'fully_fenced', 'partially_fenced', 'not_fenced')
  - space_size (required, string, max 100 chars) - allows flexibility for "500 sqft", "2 acres", etc.
  - max_dogs_per_booking (required, integer, min: 1, max: 50)
  - price_per_dog (required, decimal, precision: 8, scale: 2, min: 0.01)
- **Environment Information**:
  - other_dogs_visible_audible (required, boolean)
  - other_pets_visible_audible (required, boolean)
  - other_people_visible_audible (required, boolean)
- **Operational**:
  - status (required, enum: 'active', 'inactive', default: 'active')
  - photos (array, max 5 attachments)
- **Relationships**:
  - belongs_to :user (host)
  - timestamps (created_at, updated_at)

#### API Endpoints

**Spaces Controller** (`/api/spaces`)
- `POST /spaces` - Create new space listing
- `GET /spaces` - List all spaces for authenticated host
- `GET /spaces/:id` - Show specific space details
- `PATCH /spaces/:id` - Update space details
- `DELETE /spaces/:id` - Delete space listing
- `PATCH /spaces/:id/status` - Update space status (active/inactive)

### User Interactions and Flows

#### Create Space Flow
1. Host authenticates via existing auth system
2. Host submits space creation form with all required fields
3. System validates all input data
4. System creates space record associated with host user
5. System returns space details with generated ID
6. Photos can be uploaded separately after space creation

#### Edit Space Flow
1. Host requests to edit existing space
2. System verifies host owns the space
3. Host submits updated information
4. System validates changes
5. System updates space record
6. System returns updated space details

### Data Requirements

#### Validation Rules
- All address fields must be present and valid
- State must be valid US state abbreviation
- Zipcode must match US zipcode format (5 or 9 digits)
- Price must be positive decimal value
- Max dogs must be positive integer
- Photos must be valid image formats (jpg, png)
- Photo file size limit: 5MB per image
- Maximum 5 photos per space

#### Data Relationships
- User has_many :spaces (as host)
- Space belongs_to :user (as host)
- Space has_many_attached :photos

### Integration Points
- Integrates with existing User model and authentication system
- Uses existing photo upload/storage system
- Follows existing API response format patterns with jbuilders

## Non-Goals

### Explicitly Out of Scope
- Renter/booking functionality
- Payment processing integration
- Availability scheduling
- Search and discovery features
- Rating and review system
- Messaging between hosts and renters
- Instant booking vs. approval workflow
- Cancellation policies
- Property verification system

### Future Considerations
- Geographic search capabilities
- Advanced filtering options
- Automated pricing suggestions
- Property verification workflow
- Integration with mapping services
- Bulk space management tools

## Design Considerations

### API Design
- RESTful API following existing application patterns
- JSON request/response format
- Consistent error handling and status codes
- Proper HTTP status codes (200, 201, 400, 401, 404, 422)
- Nested routes under user context where appropriate

### Data Structure
- Normalize address data for future geographic queries
- Store pricing as decimal to avoid floating-point issues
- Use enums for controlled vocabulary fields
- Store space size as string for flexibility while maintaining searchability

### Error Handling
- Comprehensive validation error messages
- Clear field-level error responses
- Graceful handling of photo upload failures
- Proper authorization error responses

## Technical Considerations

### Performance Requirements
- Space creation should complete within 2 seconds (excluding photo uploads)
- Space listing queries should return within 500ms
- Support for up to 1000 spaces per host
- Photo uploads should handle 5MB files efficiently

### Security Considerations
- Only authenticated users can create spaces
- Hosts can only view/edit their own spaces
- Secure photo upload with file type validation
- Sanitize all user input to prevent XSS
- Rate limiting on space creation (max 10 per hour per user)

### Scalability Needs
- Database indexes on user_id, status, and location fields
- Photo storage using cloud services (S3/similar)
- Prepared for future geographic queries with proper indexing
- Support horizontal scaling of API endpoints

### Integration Requirements
- Follows existing Rails application architecture
- Uses existing authentication middleware
- Leverages existing photo upload system
- Maintains consistency with current API patterns

## Success Metrics

### Key Performance Indicators
- Number of spaces created per week
- Host registration to first space listing conversion rate
- Average time to complete space listing
- Photo upload success rate
- API response time metrics

### Acceptance Criteria
- ✅ Host can successfully create a space with all required fields
- ✅ Host can upload up to 5 photos for their space
- ✅ Host can view all their listed spaces
- ✅ Host can edit any aspect of their space listing
- ✅ Host can activate/deactivate their space
- ✅ System properly validates all input data
- ✅ System returns appropriate error messages for invalid data
- ✅ Only space owners can modify their listings
- ✅ API responses follow existing application patterns

### Quality Metrics
- All API endpoints return within performance requirements
- 99% uptime for space management functionality
- Zero data loss on space creation/updates
- 100% test coverage for space model and controller

## Open Questions

### Items Requiring Further Clarification
1. **Property Verification**: How will we verify that hosts actually own/control the properties they list? Should we implement address verification, photo verification, or manual review processes?

2. **Photo Management**: Should we implement photo ordering/primary photo selection, or is simple upload sufficient for now?

3. **Geographic Data**: Should we store latitude/longitude coordinates for future mapping features, or rely on address geocoding later?

4. **Pricing Constraints**: Should we implement minimum/maximum pricing limits to ensure reasonable market rates?

5. **Space Categories**: Should we allow hosts to categorize their spaces (backyard, dog run, field, etc.) or keep it simple?

6. **Duplicate Prevention**: How do we prevent hosts from listing the same property multiple times?

### Technical Implementation Questions
1. Should we use Rails Active Storage for photo management or integrate with a third-party service?
2. What's the preferred approach for address validation - third-party service or simple format validation?
3. Should we implement soft deletes for spaces to maintain data integrity?

### Future Planning Questions
1. When we add the renter side, should spaces have separate visibility settings?
2. Should we build the API to support future features like amenities, rules, or special instructions?
3. How should we handle timezone considerations for future booking functionality?

---

## Implementation Notes

### Database Migration Requirements
- Create spaces table with all specified fields
- Add foreign key constraint to users table  
- Create appropriate indexes for performance
- Add check constraints for enum values

### Model Implementation
- Space model with proper validations
- Active Storage attachments for photos
- Enum definitions for status and fencing_status
- Proper association with User model

### Controller Implementation
- Spaces controller with full CRUD operations
- Strong parameters for mass assignment protection
- Proper authorization checks
- Consistent error handling and response formatting

### Testing Requirements
- Unit tests for Space model validations and associations
- Controller tests for all endpoints
- Integration tests for complete user flows
- Photo upload functionality testing
