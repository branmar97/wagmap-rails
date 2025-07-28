# PRD: Space Availability and Booking System

## Introduction

We are building a comprehensive booking system that allows space hosts to define their availability and enables renters to book those available time slots. This system will facilitate the core transaction between dog space hosts and renters, moving beyond just listing spaces to actual bookings and scheduling.

### Context and Background

Currently, the platform allows users to list their dog spaces with basic information (address, fencing, pricing, etc.). The next critical step is enabling the actual booking process where renters can reserve specific time slots and hosts can manage those requests.

### Problem Statement

Space hosts need a way to communicate when their spaces are available for booking, and renters need a way to request specific time slots. Without a structured availability and booking system, potential transactions cannot be completed, limiting the platform's value.

## Goals

### Primary Objectives

- Enable hosts to define flexible availability schedules (recurring and one-time)
- Allow renters to discover and book available time slots
- Provide hosts with approval/denial workflow for booking requests
- Create a React-friendly API structure for frontend implementation
- Establish foundation for future payment integration

### Business Value

- Enables actual transactions between hosts and renters
- Provides structured data for demand analytics
- Creates engagement through booking interactions
- Establishes revenue-generating booking flow

### User Value

- **Hosts**: Control over when their space is available, ability to screen bookings
- **Renters**: Clear visibility into availability, structured booking process
- **Both**: Transparent communication through booking messages

## User Stories

### Host Stories

- As a space host, I want to set recurring availability (e.g., "every Monday 9 AM - 5 PM") so that renters know when my space is consistently available
- As a space host, I want to review booking requests with renter details and pet information so that I can make informed approval decisions
- As a space host, I want to approve or deny booking requests with optional messages so that I can communicate with renters
- As a space host, I want to cancel a booking if needed (emergency, maintenance) so that I can manage unexpected situations
- As a space host, I want to see all my pending, approved, and past bookings in one place so that I can manage my schedule

### Renter Stories

- As a renter, I want to see available time slots for a space so that I can choose when to book
- As a renter, I want to request a booking by specifying duration, start time, and which pets I'm bringing so that the host knows what to expect
- As a renter, I want to include an optional message with my booking request so that I can introduce myself or explain special circumstances
- As a renter, I want to see the calculated total cost before submitting my booking request so that I know how much I'll pay
- As a renter, I want to cancel my approved booking if my plans change so that I can free up the time slot
- As a renter, I want to see the status of all my booking requests so that I can track their progress

## Functional Requirements

### Availability Management

#### Recurring Availability
- Hosts can set weekly recurring availability patterns
- Each pattern specifies: day of week, start time, end time
- Patterns can be enabled/disabled without deletion
- Multiple patterns can exist for the same day (e.g., morning and evening slots)
- Minimum time slot: 1 hour, maximum: 8 hours per slot

#### Availability Rules
- Availability slots must be at least 1 hour duration
- Start times must be on 30-minute boundaries (e.g., 9:00, 9:30, 10:00)
- Cannot set availability more than 3 months in advance
- Hosts can modify availability up to 24 hours before the time slot

### Booking System

#### Booking Creation
- Renters can request bookings for available time slots
- Required fields: space_id, start_datetime, duration (hours), pet_ids
- Optional fields: message (up to 500 characters)
- Duration must match or be less than available slot duration
- No minimum advance notice required
- Cannot book more than 3 months in advance

#### Booking Validation
- Pet IDs must belong to the requesting user
- Start datetime must fall within an available slot
- Duration cannot exceed available slot duration
- Multiple bookings allowed for the same time slot
- Space must be active and owned by a different user

#### Booking States
- **Pending**: Initial state when created
- **Approved**: Host has approved the booking
- **Denied**: Host has denied the booking
- **Cancelled**: Booking was cancelled by host or renter
- **Completed**: Booking time has passed (automatic)

#### Host Response
- Hosts can approve or deny pending bookings
- Optional message field (up to 500 characters) for approval/denial reasoning
- Approval/denial can happen any time before booking start time
- Auto-denial after 24 hours of no response or if time has passed

#### Cancellation System
- Both hosts and renters can cancel approved bookings
- Renter cancellations within 24 hours of booking start time may forfeit refund
- Host cancellations result in full refund regardless of timing
- Cancelled bookings free up the time slot for new bookings

#### Pricing Calculation
- Pricing is per hour per dog: `total_cost = space.price_per_dog_per_hour * duration_hours * number_of_pets`
- Example: $5/hour/dog × 2 hours × 3 dogs = $30 total
- Price is calculated and stored when booking is approved

### Data Models

#### AvailabilityPattern
```
id: integer (primary key)
space_id: integer (foreign key to spaces)
day_of_week: integer (0-6, Sunday=0)
start_time: time
end_time: time
is_active: boolean (default: true)
created_at: datetime
updated_at: datetime
```

#### Booking
```
id: integer (primary key)
space_id: integer (foreign key to spaces)
renter_id: integer (foreign key to users)
start_datetime: datetime
end_datetime: datetime
duration_hours: integer
status: enum ('pending', 'approved', 'denied', 'cancelled', 'completed')
renter_message: text (optional)
host_response_message: text (optional)
host_responded_at: datetime (optional)
total_cost: decimal (calculated when approved: price_per_dog_per_hour * duration * pet_count)
cancelled_by: integer (foreign key to users, optional)
cancelled_at: datetime (optional)
cancellation_reason: text (optional)
created_at: datetime
updated_at: datetime
```

#### BookingPet
```
id: integer (primary key)
booking_id: integer (foreign key to bookings)
pet_id: integer (foreign key to pets)
created_at: datetime
```

### API Endpoints

#### Availability Management
- `GET /spaces/:id/availabilities` - Get space availability for date range
- `POST /spaces/:id/availabilities` - Create recurring availability
- `PUT /spaces/:id/availabilities/:id` - Update recurring availability
- `DELETE /spaces/:id/availabilities/:id` - Delete recurring availability

#### Booking Management
- `GET /bookings` - Get user's bookings (as renter or host)
- `POST /bookings` - Create new booking request
- `GET /bookings/:id` - Get specific booking details
- `PUT /bookings/:id/approve` - Approve booking (hosts only)
- `PUT /bookings/:id/deny` - Deny booking (hosts only)
- `PUT /bookings/:id/cancel` - Cancel booking (host or renter)
- `GET /spaces/:id/bookings` - Get bookings for a space (host only)

### Frontend Requirements

#### React-Friendly API Design
- All datetime fields in ISO 8601 format
- Consistent error response format
- Pagination for booking lists
- Filter parameters for date ranges and status

#### Calendar Integration
- API responses formatted for calendar library consumption
- Availability data structured for easy calendar rendering
- Booking data includes all necessary display information

## Non-Goals

### Phase 1 Exclusions
- Payment processing (future enhancement)
- Booking modifications after approval (future enhancement)
- Recurring booking requests (future enhancement)
- Real-time notifications (future enhancement)
- Booking reviews/ratings (future enhancement)
- Advanced pricing rules (discounts, peak pricing)

### Technical Non-Goals
- Mobile app support (web-responsive only)
- Offline functionality
- Third-party calendar integration (Google Calendar, etc.)

## Design Considerations

### User Experience
- Clear visual distinction between available and unavailable time slots
- Intuitive booking flow with confirmation steps
- Clear status indicators for all booking states
- Mobile-responsive design for calendar and booking interfaces

### Accessibility
- Calendar navigation keyboard accessible
- Screen reader friendly booking forms
- High contrast for availability indicators
- Focus management in booking modals

### Mobile Responsiveness
- Touch-friendly calendar interface
- Collapsible booking details
- Optimized form layouts for mobile
- Swipe navigation for calendar views

## Technical Considerations

### Performance Requirements
- Availability queries must complete within 500ms
- Support for up to 100 concurrent booking requests
- Efficient database queries for availability calculation
- Caching for frequently requested availability data

### Security Considerations
- Authorization: Users can only book others' spaces, not their own
- Validation: All pet IDs must belong to the requesting user
- Rate limiting: Maximum 10 booking requests per user per hour
- Data validation: All datetime inputs must be validated and sanitized

### Scalability Needs
- Database indexes on space_id, date ranges, and user_id
- Ability to handle 1000+ spaces with individual availability patterns
- Efficient availability calculation algorithms
- Background processing for booking status updates

### Integration Requirements
- Email notification system (future)
- Audit logging for all booking state changes
- Integration with existing user/space/pet models
- Future payment system integration points

## Database Design

### Indexes Required
```sql
-- Availability pattern lookups
CREATE INDEX idx_availabilities_space_day ON availabilities(space_id, day_of_week);

-- Booking queries
CREATE INDEX idx_bookings_space_datetime ON bookings(space_id, start_datetime);
CREATE INDEX idx_bookings_renter_status ON bookings(renter_id, status);
CREATE INDEX idx_bookings_status_start ON bookings(status, start_datetime);

-- Booking pets
CREATE INDEX idx_booking_pets_booking ON booking_pets(booking_id);
```

### Constraints
```sql
-- Ensure booking end time is after start time
ALTER TABLE bookings ADD CONSTRAINT check_booking_times 
  CHECK (end_datetime > start_datetime);

-- Ensure duration matches calculated time difference
ALTER TABLE bookings ADD CONSTRAINT check_duration_consistency 
  CHECK (duration_hours = EXTRACT(EPOCH FROM (end_datetime - start_datetime)) / 3600);

-- Ensure availability patterns have valid times
ALTER TABLE availabilities ADD CONSTRAINT check_availability_times 
  CHECK (end_time > start_time);
```

## Success Metrics

### Key Performance Indicators
- **Booking Request Volume**: Number of booking requests per week
- **Approval Rate**: Percentage of bookings approved vs. denied
- **Response Time**: Average time for hosts to respond to booking requests
- **Availability Utilization**: Percentage of available slots that get booked
- **User Engagement**: Number of active hosts setting availability

### Acceptance Criteria
- Hosts can successfully set recurring weekly availability patterns
- Hosts can add one-time availability exceptions
- Renters can view available time slots for any space
- Renters can successfully create booking requests with pet selection
- Hosts receive booking requests and can approve/deny with messages
- All datetime handling works correctly across time zones
- API responses are properly formatted for React frontend consumption
- Database queries perform within acceptable limits (< 500ms)

### Quality Metrics
- 99.9% API uptime
- Zero data consistency errors in booking states
- All booking state transitions logged for audit
- 100% test coverage for booking logic

## Implementation Phases

### Phase 1: Core Availability (Week 1-2)
- Database migrations for availability patterns
- Availability API endpoints
- Basic availability calculation logic
- Unit tests for availability models

### Phase 2: Booking System (Week 3-4)
- Database migrations for bookings and booking_pets
- Booking creation and management API endpoints
- Booking validation and business logic
- Host approval/denial workflow

### Phase 3: Integration & Testing (Week 5)
- End-to-end API testing
- Performance optimization
- Error handling and edge cases
- Documentation and API examples

### Phase 4: Frontend Preparation (Week 6)
- React-optimized API responses
- Frontend documentation
- API testing with sample React components
- Final bug fixes and optimization

## Open Questions

### Business Logic
1. ~~Should we allow partial bookings of available slots? (e.g., booking 2 hours of a 4-hour available slot)~~ **RESOLVED: Yes, renters can book partial slots**
2. How should we handle time zone differences between hosts and renters?
3. ~~Should there be a minimum booking duration (e.g., 1 hour minimum)?~~ **RESOLVED: Host sets minimum 1-hour availability slots**
4. What happens to pending bookings when a host modifies their availability?
5. Should we implement automatic refund calculation based on cancellation timing?

### Technical Implementation
1. Should we pre-calculate available slots or calculate them dynamically?
2. ~~How should we handle concurrent booking requests for the same time slot?~~ **RESOLVED: Multiple bookings for same time slot allowed
3. Should we implement soft deletes for bookings for audit purposes?
4. What's the best approach for handling recurring availability calculations?
5. How should we handle the automatic denial of overlapping pending bookings when one is approved?

### User Experience
1. Should hosts see renter profiles/ratings before approving bookings?
2. Should there be automatic approval options for trusted renters?
3. How much booking history should we display in the UI?
4. Should we show host response time averages to renters?

## Future Considerations

### Payment Integration
- Booking deposits and full payment processing
- Refund handling for cancellations
- Platform fee calculation and collection

### Advanced Features
- Recurring booking requests (weekly dog walking, etc.)
- Booking modifications and cancellations
- Real-time availability updates
- Calendar synchronization with external systems
- Automated booking confirmations and reminders

### Analytics and Insights
- Host revenue analytics
- Renter booking history and preferences
- Space utilization reports
- Demand forecasting for pricing optimization
