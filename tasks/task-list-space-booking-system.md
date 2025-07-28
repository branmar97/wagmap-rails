# Task List: Space Availability and Booking System

**Generated from:** `prd-space-booking-system.md`  
**Target:** Junior Developer  
**Estimated Duration:** 80-100 hours (4-5 weeks)

## Overview

This task list implements a comprehensive booking system that allows space hosts to define availability patterns and enables renters to book time slots with approval workflows. The system includes recurring availability, one-time exceptions, competitive booking, and cancellation functionality.

## Task Categories

### Setup & Infrastructure

- [x] **T001: Database Schema Setup**
  - [x] Create migration for `availabilities` table
    - Add fields: space_id, day_of_week, start_time, end_time, is_active
    - Add foreign key constraint to spaces table
    - Add indexes for space_id and day_of_week lookups
  - [x] Create migration for `bookings` table
    - Add all required fields including status enum, pricing, cancellation tracking
    - Add foreign key constraints to spaces and users tables
    - Add check constraints for booking times and duration consistency
    - Add indexes for efficient querying
  - [x] Create migration for `booking_pets` junction table
    - Add booking_id and pet_id with foreign key constraints
    - Add composite index on booking_id and pet_id
  - **Duration:** 2-3 hours
  - **Files:** `db/migrate/[timestamp]_create_availabilities.rb`, `db/migrate/[timestamp]_create_bookings.rb`, `db/migrate/[timestamp]_create_booking_pets.rb`

### Data Layer - Models

- [x] **T002: Model Development and Relationships**
  - [x] Create `Availability` model
    - Define fields: space_id, day_of_week, start_time, end_time, is_active
    - Add validations for day_of_week (0-6), time formats, business logic rules
    - Add association to space (belongs_to)
    - Add scopes for active patterns, specific days, time ranges
  - [x] Create `Booking` model
    - Define fields: space_id, user_id, booking_date, start_time, end_time, duration, status, total_price, cancellation_deadline, cancelled_at
    - Add validations for required fields, time ranges, status transitions
    - Add associations to space, user, and pets (through booking_pets)
    - Add state machine for booking status
    - Add methods for pricing calculations, cancellation rules
  - [x] Create `BookingPet` model
    - Define fields: booking_id, pet_id
    - Add composite unique index on booking_id and pet_id
    - Add associations to booking and pet
  - [x] Update existing `Space` model
    - Add association: has_many :availabilities, dependent: :destroy
    - Add association: has_many :bookings, dependent: :destroy
    - Add instance methods for availability checking, pricing
    - Add scopes for bookable spaces
  - **Duration:** 3-4 hours
  - **Files:** `app/models/availability.rb`, `app/models/booking.rb`, `app/models/booking_pet.rb`, `app/models/space.rb`

- [ ] **T003: Booking Model**
  - [ ] Create Booking model with all associations
    - belongs_to :space, :renter (class_name: 'User')
    - has_many :booking_pets, :pets (through: booking_pets)
    - belongs_to :cancelled_by (class_name: 'User', optional: true)
  - [ ] Add status enum with all states
    - pending, approved, denied, cancelled, completed
    - Add status transition validations
  - [ ] Add business logic methods
    - pricing calculation (price_per_dog * duration * pet_count)
    - time slot validation
    - overlap detection
    - automatic status transitions (completed after end_datetime)
  - [ ] Add validation methods
    - start_datetime < end_datetime
    - duration_hours matches calculated time difference
    - pet ownership validation
    - space ownership validation (can't book own space)
  - **Duration:** 4-5 hours
  - **Files:** `app/models/booking.rb`

- [ ] **T004: BookingPet Model & Space Model Updates**
  - [ ] Create BookingPet junction model
    - belongs_to :booking, :pet
    - validation for pet ownership matching booking renter
  - [ ] Update Pet model if needed
    - has_many :booking_pets, :bookings (through: booking_pets)
  - **Duration:** 2 hours
  - **Files:** `app/models/booking_pet.rb`, `app/models/space.rb`, `app/models/pet.rb`

### Business Logic - Services

- [ ] **T005: Availability Calculator Service**
  - [ ] Create AvailabilityCalculator service class
    - Calculate available slots for a space and date range
    - Handle recurring patterns only (no exceptions)
    - Return time slots in React-friendly format
  - [ ] Add methods for different calculation scenarios
    - get_available_slots(space, start_date, end_date)
    - check_slot_availability(space, start_datetime, duration)
    - get_conflicting_bookings(space, start_datetime, end_datetime)
  - [ ] Optimize for performance with caching considerations
  - **Duration:** 3-4 hours
  - **Files:** `app/services/availability_calculator.rb`

- [ ] **T006: Booking Manager Service**
  - [ ] Create BookingManager service class
    - Handle booking creation with validation
    - Manage booking approval/denial workflow
    - Handle automatic denial of overlapping pending bookings
    - Calculate and store total cost on approval
  - [ ] Add booking state transition methods
    - approve_booking(booking, host_message)
    - deny_booking(booking, host_message)
    - cancel_booking(booking, cancelled_by, reason)
    - auto_complete_expired_bookings
  - [ ] Add conflict resolution logic
    - When booking approved, auto-deny overlapping pending bookings
    - Validate no approved bookings exist for same time slot
  - **Duration:** 4-5 hours
  - **Files:** `app/services/booking_manager.rb`

### API Layer - Controllers

- [ ] **T007: AvailabilitiesController**
  - [ ] Create nested resource controller (under spaces)
    - before_action :authenticate_user!, :find_space, :authorize_space_owner
    - index, create, update, destroy actions
  - [ ] Implement CRUD operations
    - GET /spaces/:id/availabilities - list patterns
    - POST /spaces/:id/availabilities - create pattern
    - PUT /spaces/:id/availabilities/:id - update pattern
    - DELETE /spaces/:id/availabilities/:id - soft delete pattern
  - [ ] Add validation and error handling
    - Strong parameters for pattern attributes
    - Overlap detection and conflict resolution
    - JSON error responses with specific messages
  - **Duration:** 3-4 hours
  - **Files:** `app/controllers/availabilities_controller.rb`

- [ ] **T008: Spaces Availability Endpoint**
  - [ ] Add availability action to SpacesController
    - GET /spaces/:id/availability?start_date=X&end_date=Y
    - Public endpoint (no authentication required for viewing)
    - Use AvailabilityCalculator service
  - [ ] Format response for React calendar consumption
    - Return available time slots with start/end times
    - Include pricing information per slot
    - Filter out past dates automatically
  - [ ] Add query parameter validation
    - Validate date format and range (max 3 months)
    - Default to next 30 days if no range specified
    - Handle timezone considerations
  - **Duration:** 2-3 hours
  - **Files:** `app/controllers/spaces_controller.rb`

- [ ] **T009: BookingsController - Core CRUD**
  - [ ] Create BookingsController with authentication
    - before_action :authenticate_user! for all actions
    - index, show, create actions for all users
  - [ ] Implement booking creation (POST /bookings)
    - Strong parameters for booking attributes
    - Pet ownership validation
    - Available slot validation using AvailabilityCalculator
    - Use BookingManager service for creation
  - [ ] Implement user's bookings list (GET /bookings)
    - Return bookings where user is renter OR space owner
    - Add filtering by status, date range
    - Paginate results for performance
    - Include associated space and pet data
  - [ ] Implement booking details (GET /bookings/:id)
    - Authorization: renter or space owner only
    - Include all related data (space, pets, messages)
  - **Duration:** 4-5 hours
  - **Files:** `app/controllers/bookings_controller.rb`

- [ ] **T010: BookingsController - Host Actions**
  - [ ] Add host-specific booking actions
    - PUT /bookings/:id/approve - approve booking (space owners only)
    - PUT /bookings/:id/deny - deny booking (space owners only)
    - Authorization checks for space ownership
  - [ ] Implement approval workflow
    - Update booking status and host_response_message
    - Calculate and store total_cost
    - Use BookingManager to auto-deny overlapping bookings
    - Validate booking hasn't started yet
  - [ ] Implement denial workflow
    - Update status and optional host message
    - Log denial reason for analytics
  - [ ] Add space bookings endpoint
    - GET /spaces/:id/bookings - for space owners only
    - Filter by status, date range
    - Include renter and pet information
  - **Duration:** 3-4 hours
  - **Files:** `app/controllers/bookings_controller.rb`

- [ ] **T011: BookingsController - Cancellation**
  - [ ] Add cancellation action
    - PUT /bookings/:id/cancel - for renter or space owner
    - Authorization: booking renter or space owner only
  - [ ] Implement cancellation logic
    - Check booking status (can only cancel approved bookings)
    - Use BookingManager service for cancellation
    - Store cancelled_by, cancelled_at, cancellation_reason
    - Free up time slot for new bookings
  - [ ] Add refund eligibility calculation
    - Check if renter cancelling within 24 hours
    - Store refund eligibility for future payment integration
    - Different rules for host vs renter cancellation
  - **Duration:** 2-3 hours
  - **Files:** `app/controllers/bookings_controller.rb`

### API Layer - Views (JSON)

- [ ] **T012: Availability JSON Views**
  - [ ] Create availabilities JSON views
    - _availability.json.jbuilder partial
    - index.json.jbuilder for pattern listing
    - Include day_of_week names, formatted times
  - [ ] Create availability_exceptions JSON views
    - _availability_exception.json.jbuilder partial
    - index.json.jbuilder for exception listing
    - Format dates and times for React consumption
  - [ ] Create spaces availability JSON view
    - availability.json.jbuilder for main availability endpoint
    - Structure data for calendar library consumption
    - Include available slots with pricing information
  - **Duration:** 2-3 hours
  - **Files:** `app/views/availabilities/`, `app/views/availability_exceptions/`, `app/views/spaces/availability.json.jbuilder`

- [ ] **T013: Booking JSON Views**
  - [ ] Create booking JSON views
    - _booking.json.jbuilder partial with all fields
    - index.json.jbuilder for booking lists
    - show.json.jbuilder for booking details
  - [ ] Include associated data efficiently
    - Space information (name, address, pricing)
    - Pet information (names, breeds)
    - Renter information (name, contact) for hosts
    - Host information (name, response) for renters
  - [ ] Format datetime fields in ISO 8601
    - All datetime fields in consistent format
    - Include timezone information
    - Calculate derived fields (time_until_start, duration_readable)
  - **Duration:** 2-3 hours
  - **Files:** `app/views/bookings/`

### Routes Configuration

- [ ] **T014: Routes Setup**
  - [ ] Add nested routes for availability management
    - resources :spaces do resources :availabilities, :availability_exceptions
    - member route for spaces availability GET :availability
  - [ ] Add booking routes
    - resources :bookings with member actions for approve, deny, cancel
    - nested route for space bookings: GET /spaces/:id/bookings
  - [ ] Configure route constraints and filters
    - API versioning considerations
    - Rate limiting setup for booking creation
  - **Duration:** 1 hour
  - **Files:** `config/routes.rb`

### Testing - Models

- [ ] **T015: Model Tests - Availability**
  - [ ] Test Availability model
    - Validation tests (day_of_week, time range, space association)
    - Business logic tests (overlap detection, time calculations)
    - Scope and query method tests
  - [ ] Test AvailabilityException model
    - Validation tests (date range, exception types, conflicts)
    - Business logic tests (pattern overrides, availability calculations)
  - [ ] Create comprehensive test fixtures
    - Sample patterns for different days and times
    - Exception examples (blocks and additions)
    - Edge cases and boundary conditions
  - **Duration:** 3-4 hours
  - **Files:** `test/models/availability_test.rb`, `test/models/availability_exception_test.rb`, `test/fixtures/availabilities.yml`, `test/fixtures/availability_exceptions.yml`

- [ ] **T016: Model Tests - Bookings**
  - [ ] Test Booking model thoroughly
    - All validation tests (times, associations, business rules)
    - Status transition tests (pending → approved/denied/cancelled)
    - Pricing calculation tests with different scenarios
    - Overlap detection and conflict resolution
  - [ ] Test BookingPet junction model
    - Association validations
    - Pet ownership validation
  - [ ] Create booking test fixtures
    - Various booking states and scenarios
    - Different time ranges and pet combinations
    - Conflict scenarios for testing
  - **Duration:** 4-5 hours
  - **Files:** `test/models/booking_test.rb`, `test/models/booking_pet_test.rb`, `test/fixtures/bookings.yml`, `test/fixtures/booking_pets.yml`

### Testing - Services

- [ ] **T017: Service Tests - Availability Calculator**
  - [ ] Test AvailabilityCalculator service
    - Test available slot calculation with various patterns
    - Test exception handling (blocks and additions)
    - Test edge cases (midnight spans, DST transitions)
    - Test performance with large datasets
  - [ ] Test booking conflict detection
    - Test overlap detection with existing bookings
    - Test partial slot availability
    - Test concurrent booking scenarios
  - [ ] Mock external dependencies and test isolation
  - **Duration:** 3-4 hours
  - **Files:** `test/services/availability_calculator_test.rb`

- [ ] **T018: Service Tests - Booking Manager**
  - [ ] Test BookingManager service
    - Test booking creation with validation
    - Test approval/denial workflows
    - Test automatic denial of overlapping bookings
    - Test pricing calculation and storage
  - [ ] Test cancellation workflows
    - Test host vs renter cancellation rules
    - Test refund eligibility calculation
    - Test time slot liberation after cancellation
  - [ ] Test error handling and edge cases
    - Concurrent booking attempts
    - Invalid state transitions
    - Database constraint violations
  - **Duration:** 3-4 hours
  - **Files:** `test/services/booking_manager_test.rb`

### Testing - Controllers

- [ ] **T019: Controller Tests - Availability Management**
  - [ ] Test AvailabilitiesController
    - Authentication and authorization tests
    - CRUD operation tests with valid/invalid data
    - Error handling and validation responses
    - JSON response format verification
  - [ ] Test AvailabilityExceptionsController
    - Similar test coverage as patterns controller
    - Exception-specific business logic tests
  - [ ] Test Spaces availability endpoint
    - Public access verification
    - Date range validation
    - Response format for React consumption
    - Performance with large availability datasets
  - **Duration:** 4-5 hours
  - **Files:** `test/controllers/availabilities_controller_test.rb`, `test/controllers/availability_exceptions_controller_test.rb`, `test/controllers/spaces_controller_test.rb`

- [ ] **T020: Controller Tests - Bookings**
  - [ ] Test BookingsController CRUD operations
    - Authentication requirements for all actions
    - Booking creation with validation
    - Index filtering and pagination
    - Authorization for viewing bookings
  - [ ] Test host-specific actions
    - Approval/denial authorization and workflow
    - Space bookings endpoint access control
    - Overlapping booking auto-denial
  - [ ] Test cancellation functionality
    - Authorization for cancellation
    - Different cancellation rules for hosts vs renters
    - State transition validation
  - **Duration:** 5-6 hours
  - **Files:** `test/controllers/bookings_controller_test.rb`

### Testing - Integration

- [ ] **T021: Integration Tests - Booking Workflow**
  - [ ] Test complete booking workflow end-to-end
    - Host sets availability → Renter views slots → Creates booking → Host approves → Booking confirmed
    - Test with multiple competing bookings for same slot
    - Test cancellation scenarios
  - [ ] Test availability calculation integration
    - Complex scenarios with patterns and exceptions
    - Real-time availability updates
    - Performance under load
  - [ ] Test error scenarios and edge cases
    - Invalid data submissions
    - Concurrent user actions
    - Time zone edge cases
  - **Duration:** 4-5 hours
  - **Files:** `test/integration/booking_workflow_test.rb`

- [ ] **T022: Integration Tests - API Responses**
  - [ ] Test JSON API response formats
    - All endpoints return consistent error formats
    - DateTime fields in ISO 8601 format
    - Proper HTTP status codes
    - React-friendly data structures
  - [ ] Test pagination and filtering
    - Booking lists with various filters
    - Performance with large datasets
    - Consistent pagination format
  - [ ] Test authentication and authorization flows
    - JWT token validation across all endpoints
    - Proper access control enforcement
    - Error messages for unauthorized access
  - **Duration:** 3-4 hours
  - **Files:** `test/integration/api_responses_test.rb`

### Background Jobs & Maintenance

- [ ] **T023: Automated Booking Status Updates**
  - [ ] Create background job for booking status updates
    - Auto-complete bookings after end_datetime
    - Auto-deny bookings after 24 hours no response
    - Clean up expired pending bookings
  - [ ] Add job scheduling configuration
    - Set up periodic job execution (every hour)
    - Add job monitoring and error handling
    - Log job execution for debugging
  - [ ] Test job functionality
    - Test status transition logic
    - Test job scheduling and execution
    - Test error handling and retries
  - **Duration:** 3-4 hours
  - **Files:** `app/jobs/booking_status_updater_job.rb`, job scheduling configuration

### Documentation & API Specs

- [ ] **T024: API Documentation**
  - [ ] Create comprehensive API documentation
    - Document all availability management endpoints
    - Document all booking management endpoints
    - Include request/response examples
    - Document error codes and messages
  - [ ] Add React integration examples
    - Sample API calls for common scenarios
    - Calendar integration examples
    - Booking form implementation guide
  - [ ] Document business rules and constraints
    - Availability rules and limitations
    - Booking validation requirements
    - Pricing calculation formulas
  - **Duration:** 3-4 hours
  - **Files:** `docs/booking-system-api.md`

### Performance Optimization

- [ ] **T025: Database Optimization**
  - [ ] Add database indexes for performance
    - Implement all indexes specified in PRD
    - Add composite indexes for common query patterns
    - Analyze query performance and optimize
  - [ ] Add caching for availability calculations
    - Cache available slots for popular spaces
    - Implement cache invalidation on availability changes
    - Add cache warming for frequently accessed data
  - [ ] Optimize booking queries
    - Eager loading for associated data
    - Efficient filtering and pagination
    - Query optimization for complex availability calculations
  - **Duration:** 2-3 hours
  - **Files:** Database migration files, caching configuration

## Task Dependencies

### Critical Path Dependencies
- T001 (Database Schema) → T002, T003, T004 (All Models)
- T002, T003, T004 (Models) → T005, T006 (Services)
- T005, T006 (Services) → T007, T008, T009, T010, T011 (Controllers)
- Controllers → T012, T013 (JSON Views)
- T014 (Routes) can be done in parallel with Controllers
- All core functionality → Testing tasks (T015-T022)
- T023 (Background Jobs) depends on T003 (Booking Model)
- T024 (Documentation) can be done after Controllers are complete
- T025 (Performance) should be done after basic functionality is working

### Parallel Development Opportunities
- Model tests can be written alongside model development
- JSON views can be developed in parallel with controllers
- Service tests can be written while services are being developed
- Documentation can be started once API structure is defined

## Estimated Timeline

### Week 1: Foundation (18-22 hours)
- T001: Database Schema Setup
- T002, T003, T004: All Model Development
- T015, T016: Model Tests

### Week 2: Business Logic (18-22 hours)
- T005: Availability Calculator Service
- T006: Booking Manager Service
- T017, T018: Service Tests
- T014: Routes Setup

### Week 3: API Development (18-22 hours)
- T007, T008: Availability Controllers
- T009, T010, T011: Booking Controllers
- T012, T013: JSON Views
- T019, T020: Controller Tests

### Week 4: Integration & Polish (15-20 hours)
- T021, T022: Integration Tests
- T023: Background Jobs
- T024: API Documentation
- T025: Database Optimization
- T027: Performance Optimization

## Quality Gates

Each task must meet these criteria before completion:
- [ ] All code is tested with appropriate coverage
- [ ] All validations handle edge cases properly
- [ ] JSON responses are properly formatted for React
- [ ] Error messages are user-friendly and actionable
- [ ] Performance requirements are met (< 500ms for availability queries)
- [ ] Security considerations are properly implemented
- [ ] Code follows Rails conventions and best practices

## Final Deliverables

Upon completion, the system will provide:
1. **Complete availability management** - hosts can set recurring patterns and exceptions
2. **Robust booking system** - competitive booking with approval workflow
3. **Comprehensive API** - React-ready endpoints with proper error handling
4. **Full test coverage** - unit, integration, and end-to-end tests
5. **Performance optimization** - efficient queries and caching
6. **Complete documentation** - API docs and integration examples
7. **Background processing** - automated status updates and maintenance

## Success Metrics Validation

Before considering the implementation complete, verify:
- [ ] Hosts can successfully set and modify availability patterns
- [ ] Renters can view available slots and create booking requests
- [ ] Competitive booking system works (multiple requests, first approval wins)
- [ ] All booking states transition correctly
- [ ] Pricing calculations are accurate
- [ ] Cancellation system works for both hosts and renters
- [ ] API responses are properly formatted for React consumption
- [ ] All database queries perform within 500ms
- [ ] System handles concurrent users without data corruption
