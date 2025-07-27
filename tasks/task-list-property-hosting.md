# Task List: Property Hosting (Spaces) - Host Experience

**Generated from:** `prd-property-hosting.md`
**Target:** Junior Developer
**Estima### Documentation & Finalization
- [ ] **T013: Update API Documentation**
  - [ ] Document all new endpoints
  - [ ] Include request/response examples
  - [ ] Document error responses
  - [ ] Update any existing API documentation
  - **Duration:** 1 hour
  - **Files:** API documentation files

- [ ] **T014: Code Review & Cleanup**
  - [ ] Review all code for Rails conventions
  - [ ] Ensure consistent error handling
  - [ ] Verify security measures are in place
  - [ ] Check for any remaining TODOs or debugging code
  - [ ] Ensure all tests pass
  - **Duration:** 1 hour
  - **Files:** All created files6-20 hours

## Task Categories

### Setup & Infrastructure
- [x] **T001: Review Existing Codebase**
  - [x] Examine current User model and authentication system
  - [x] Review existing API patterns and response formats
  - [x] Check current photo upload/storage implementation
  - [x] Understand existing jbuilder patterns
  - **Duration:** 1 hour
  - **Files:** `app/models/user.rb`, `app/controllers/application_controller.rb`, existing controllers

### Data Layer
- [x] **T002: Create Space Migration**
  - [x] Create migration file for spaces table
  - [x] Add all required fields (address1, address2, city, state, zipcode)
  - [x] Add property details (fencing_status, space_size, max_dogs_per_booking, price_per_dog)
  - [x] Add environment booleans (other_dogs_visible_audible, other_pets_visible_audible, other_people_visible_audible)
  - [x] Add status enum with default 'active'
  - [x] Add foreign key to users table with proper constraints
  - [x] Add indexes on user_id, status, and location fields
  - [x] Add check constraints for enum values
  - **Duration:** 1-2 hours
  - **Files:** `db/migrate/[timestamp]_create_spaces.rb`

- [x] **T003: Create Space Model**
  - [x] Generate Space model class
  - [x] Add belongs_to :user association
  - [x] Define fencing_status enum ('fully_fenced', 'partially_fenced', 'not_fenced')
  - [x] Define status enum ('active', 'inactive') with default 'active'
  - [x] Add has_many_attached :photos for Active Storage
  - [x] Add comprehensive validations:
    - Presence validations for required fields
    - Length validations (address1: 255, address2: 255, city: 100, state: 2, zipcode: 10, space_size: 100)
    - Format validation for state (2-letter US state codes)
    - Format validation for zipcode (5 or 9 digits)
    - Numericality validations (price_per_dog > 0, max_dogs_per_booking 1-50)
  - **Duration:** 2-3 hours
  - **Files:** `app/models/space.rb`

- [x] **T004: Update User Model**
  - [x] Add has_many :spaces association to User model
  - [x] Add dependent: :destroy option for cascade deletion
  - **Duration:** 15 minutes
  - **Files:** `app/models/user.rb`

### Business Logic & API
- [x] **T005: Create Spaces Controller**
  - [x] Generate SpacesController with authentication
  - [x] Implement index action (list user's spaces)
    - Filter spaces by current_user
    - Return JSON with proper status codes
  - [x] Implement show action (get specific space)
    - Verify space belongs to current_user
    - Return 404 if not found or unauthorized
  - [x] Implement create action
    - Use strong parameters
    - Associate space with current_user
    - Handle validation errors with proper JSON response
    - Return 201 on success with space details
  - [x] Implement update action
    - Verify ownership before update
    - Use strong parameters
    - Handle validation errors
    - Return updated space details
  - [x] Implement destroy action
    - Verify ownership before deletion
    - Return 204 on successful deletion
  - [x] Add before_action for authentication
  - [x] Add before_action for finding and authorizing space
  - **Duration:** 3-4 hours
  - **Files:** `app/controllers/spaces_controller.rb`

- [x] **T006: Implement Strong Parameters**
  - [x] Define space_params private method
  - [x] Permit all required fields for create/update
  - [x] Ensure security by only permitting allowed attributes
  - **Duration:** 30 minutes
  - **Files:** `app/controllers/spaces_controller.rb`

- [x] **T007: Add Routes Configuration**
  - [x] Add spaces resources to routes.rb
  - [x] Configure nested routes under authenticated context if needed
  - [x] Add custom route for status updates if required
  - **Duration:** 15 minutes
  - **Files:** `config/routes.rb`

- [x] **T008: Create Jbuilder Views**
  - [x] Create _space.json.jbuilder partial
    - Include all space attributes
    - Format timestamps appropriately
  - [x] Create index.json.jbuilder
    - Use partial to render array of spaces
    - Include pagination info if needed
  - [x] Create show.json.jbuilder
    - Use partial to render single space
    - Include full space details
  - **Duration:** 1-2 hours
  - **Files:** `app/views/spaces/_space.json.jbuilder`, `app/views/spaces/index.json.jbuilder`, `app/views/spaces/show.json.jbuilder`

### Testing
- [x] **T009: Write Space Model Tests**
  - [x] Test all validations (presence, length, format, numericality)
  - [x] Test enum behaviors for fencing_status and status
  - [x] Test associations (belongs_to :user)
  - [x] Test edge cases and boundary conditions
  - **Duration:** 2-3 hours
  - **Files:** `test/models/space_test.rb`

- [x] **T010: Write Spaces Controller Tests**
  - [x] Test authentication requirements
  - [x] Test index action (returns user's spaces only)
  - [x] Test show action (authorization and not found scenarios)
  - [x] Test create action (success and validation failure cases)
  - [x] Test update action (success, validation, and authorization)
  - [x] Test destroy action (success and authorization)
  - [x] Test strong parameters enforcement
  - [x] Test JSON response formats
  - **Duration:** 3-4 hours
  - **Files:** `test/controllers/spaces_controller_test.rb`

- [x] **T011: Create Test Fixtures**
  - [x] Create spaces.yml fixture file
  - [x] Add sample space data for testing
  - [x] Include various scenarios (different users, statuses, etc.)
  - **Duration:** 30 minutes
  - **Files:** `test/fixtures/spaces.yml`

- [x] **T012: Integration Tests**
  - [x] Write comprehensive integration tests covering full API workflows
  - [x] Test authentication and authorization flows
  - [x] Test all CRUD operations end-to-end
  - [x] Test error handling and edge cases
  - **Duration:** 1.5 hours
  - **Files:** `test/integration/spaces_api_test.rb`

### Documentation & Finalization
- [x] **T013: API Documentation**
  - [x] Update API documentation with new endpoints and examples
  - [x] Document request/response formats
  - [x] Include authentication requirements
  - [x] Add usage examples
  - **Duration:** 1 hour
  - **Files:** `docs/spaces-api.md`

- [ ] **T015: Code Review & Cleanup**
  - [ ] Review all code for Rails conventions
  - [ ] Ensure consistent error handling
  - [ ] Verify security measures are in place
  - [ ] Check for any remaining TODOs or debugging code
  - [ ] Ensure all tests pass
  - **Duration:** 1 hour
  - **Files:** All created files

## Task Dependencies

**Critical Path:**
- T001 (Review) → T002 (Migration) → T003 (Model) → T005 (Controller)
- T002 (Migration) must be completed before T003 (Model)
- T003 (Model) must be completed before T005 (Controller)
- T004 (User Model) can be done in parallel with T003
- T007 (Routes) should be done after T005 (Controller)
- T008 (Jbuilder) depends on T005 (Controller)

**Testing Dependencies:**
- T009 (Model Tests) depends on T003 (Model)
- T010 (Controller Tests) depends on T005 (Controller) and T008 (Jbuilder)
- T011 (Fixtures) can be done in parallel with other testing tasks
- T012 (Integration Tests) depends on T005 (Controller) and T008 (Jbuilder)

**Final Tasks:**
- T013 (Documentation) and T014 (Cleanup) should be done last

## Detailed Implementation Notes

### Database Schema
```ruby
# Migration structure
create_table :spaces do |t|
  t.references :user, null: false, foreign_key: true
  t.string :address1, null: false, limit: 255
  t.string :address2, limit: 255
  t.string :city, null: false, limit: 100
  t.string :state, null: false, limit: 2
  t.string :zipcode, null: false, limit: 10
  t.string :fencing_status, null: false
  t.string :space_size, null: false, limit: 100
  t.integer :max_dogs_per_booking, null: false
  t.decimal :price_per_dog, precision: 8, scale: 2, null: false
  t.boolean :other_dogs_visible_audible, null: false
  t.boolean :other_pets_visible_audible, null: false
  t.boolean :other_people_visible_audible, null: false
  t.string :status, null: false, default: 'active'
  t.timestamps
end

add_index :spaces, :user_id
add_index :spaces, :status
add_index :spaces, [:city, :state]
```

### API Endpoints Summary
- `GET /spaces` - List authenticated user's spaces
- `POST /spaces` - Create new space
- `GET /spaces/:id` - Show specific space (owned by user)
- `PATCH /spaces/:id` - Update space (owned by user)
- `DELETE /spaces/:id` - Delete space (owned by user)

### Key Validation Rules
- Address fields: presence and length validation
- State: format validation for 2-letter US codes
- Zipcode: format validation for 5 or 9 digits
- Price: positive decimal value
- Max dogs: integer between 1 and 50

### Security Considerations
- All endpoints require authentication
- Users can only access their own spaces
- Strong parameters prevent mass assignment
- Rate limiting may be added later

## Files to be Created/Modified

### New Files
- `db/migrate/20250727124147_create_spaces.rb` ✅
- `app/models/space.rb` ✅
- `app/controllers/spaces_controller.rb` ✅
- `app/views/spaces/_space.json.jbuilder` ✅
- `app/views/spaces/index.json.jbuilder` ✅
- `app/views/spaces/show.json.jbuilder` ✅
- `test/models/space_test.rb`
- `test/controllers/spaces_controller_test.rb`
- `test/fixtures/spaces.yml`
- `test/integration/space_management_test.rb`

### Modified Files
- `app/models/user.rb` (add has_many :spaces) ✅
- `config/routes.rb` (add spaces routes) ✅

## Success Criteria
- All tests pass with 100% coverage for new code
- All API endpoints return appropriate responses
- Authentication and authorization work properly
- Data validation prevents invalid records
- Performance meets requirements (space creation < 2 seconds, listing < 500ms)

---

**Ready to proceed?** Does this task breakdown look correct? Should we proceed with implementation starting with T001?
