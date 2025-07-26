# Wagmap Rails API

The Wagmap API that powers a React frontend for connecting dog owners with private dog park rentals. Think Airbnb, but for dogs! Users can discover and book private dog parks, yards, and play spaces for their furry friends.

## Features

- **Pet Profiles**: Users can create detailed profiles for their dogs including breed information, age, and compatibility preferences  
- **Private Dog Park Listings**: Browse and search available private dog parks and yards
- **Booking System**: Reserve dog parks for specific dates and times
- **Breed Database**: Comprehensive database of 150+ dog breeds for accurate pet profiling

## Ruby Version
- Ruby 3.3.8

## Getting Started

### Prerequisites
- Ruby 3.3.8
- Rails 7.2
- PostgreSQL

### Installation

1. Clone the repository
```bash
git clone <repository-url>
cd wagmap-rails
```

2. Install dependencies
```bash
bundle install
```

3. Database setup
```bash
rails db:create
rails db:migrate
rails db:seed
```

4. Start the server
```bash
rails server
```

The API will be available at `http://localhost:3000`
