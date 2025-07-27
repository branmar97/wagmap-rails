require "test_helper"

class SpaceTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @space = Space.new(
      user: @user,
      address1: "123 Test Street",
      address2: "Apt 4B",
      city: "Test City",
      state: "CA",
      zipcode: "12345",
      fencing_status: "fully_fenced",
      space_size: "1000 sqft",
      max_dogs_per_booking: 5,
      price_per_dog: 15.50,
      other_dogs_visible_audible: false,
      other_pets_visible_audible: true,
      other_people_visible_audible: false
    )
  end

  test "should be valid with all required attributes" do
    assert @space.valid?
  end

  test "should belong to user" do
    assert_respond_to @space, :user
    assert_equal @user, @space.user
  end

  # Presence validations
  test "should require address1" do
    @space.address1 = nil
    assert_not @space.valid?
    assert_includes @space.errors[:address1], "can't be blank"
  end

  test "should require city" do
    @space.city = nil
    assert_not @space.valid?
    assert_includes @space.errors[:city], "can't be blank"
  end

  test "should require state" do
    @space.state = nil
    assert_not @space.valid?
    assert_includes @space.errors[:state], "can't be blank"
  end

  test "should require zipcode" do
    @space.zipcode = nil
    assert_not @space.valid?
    assert_includes @space.errors[:zipcode], "can't be blank"
  end

  test "should require fencing_status" do
    @space.fencing_status = nil
    assert_not @space.valid?
    assert_includes @space.errors[:fencing_status], "can't be blank"
  end

  test "should require space_size" do
    @space.space_size = nil
    assert_not @space.valid?
    assert_includes @space.errors[:space_size], "can't be blank"
  end

  test "should require max_dogs_per_booking" do
    @space.max_dogs_per_booking = nil
    assert_not @space.valid?
    assert_includes @space.errors[:max_dogs_per_booking], "can't be blank"
  end

  test "should require price_per_dog" do
    @space.price_per_dog = nil
    assert_not @space.valid?
    assert_includes @space.errors[:price_per_dog], "can't be blank"
  end

  test "should require user" do
    @space.user = nil
    assert_not @space.valid?
    assert_includes @space.errors[:user], "must exist"
  end

  # Length validations
  test "should reject address1 that is too long" do
    @space.address1 = "a" * 256
    assert_not @space.valid?
    assert_includes @space.errors[:address1], "is too long (maximum is 255 characters)"
  end

  test "should accept address1 at maximum length" do
    @space.address1 = "a" * 255
    assert @space.valid?
  end

  test "should reject address2 that is too long" do
    @space.address2 = "a" * 256
    assert_not @space.valid?
    assert_includes @space.errors[:address2], "is too long (maximum is 255 characters)"
  end

  test "should accept nil address2" do
    @space.address2 = nil
    assert @space.valid?
  end

  test "should reject city that is too long" do
    @space.city = "a" * 101
    assert_not @space.valid?
    assert_includes @space.errors[:city], "is too long (maximum is 100 characters)"
  end

  test "should reject space_size that is too long" do
    @space.space_size = "a" * 101
    assert_not @space.valid?
    assert_includes @space.errors[:space_size], "is too long (maximum is 100 characters)"
  end

  # Format validations
  test "should require valid state format" do
    invalid_states = ["C", "CAL", "ca", "12", "C1"]
    invalid_states.each do |state|
      @space.state = state
      assert_not @space.valid?, "#{state} should be invalid"
      assert_includes @space.errors[:state], "must be a valid 2-letter US state code"
    end
  end

  test "should accept valid state format" do
    valid_states = ["CA", "NY", "TX", "FL"]
    valid_states.each do |state|
      @space.state = state
      assert @space.valid?, "#{state} should be valid"
    end
  end

  test "should require valid zipcode format" do
    invalid_zipcodes = ["1234", "123456", "12345-", "12345-123", "abcde", "12345-abcd"]
    invalid_zipcodes.each do |zipcode|
      @space.zipcode = zipcode
      assert_not @space.valid?, "#{zipcode} should be invalid"
      assert_includes @space.errors[:zipcode], "must be a valid US zipcode (5 or 9 digits)"
    end
  end

  test "should accept valid zipcode formats" do
    valid_zipcodes = ["12345", "12345-6789"]
    valid_zipcodes.each do |zipcode|
      @space.zipcode = zipcode
      assert @space.valid?, "#{zipcode} should be valid"
    end
  end

  # Numericality validations
  test "should require positive price_per_dog" do
    @space.price_per_dog = 0
    assert_not @space.valid?
    assert_includes @space.errors[:price_per_dog], "must be greater than 0"

    @space.price_per_dog = -5.00
    assert_not @space.valid?
    assert_includes @space.errors[:price_per_dog], "must be greater than 0"
  end

  test "should accept positive price_per_dog" do
    @space.price_per_dog = 0.01
    assert @space.valid?

    @space.price_per_dog = 999.99
    assert @space.valid?
  end

  test "should require max_dogs_per_booking to be integer" do
    @space.max_dogs_per_booking = 5.5
    assert_not @space.valid?
    assert_includes @space.errors[:max_dogs_per_booking], "must be an integer"
  end

  test "should require max_dogs_per_booking within range" do
    @space.max_dogs_per_booking = 0
    assert_not @space.valid?
    assert_includes @space.errors[:max_dogs_per_booking], "must be in 1..50"

    @space.max_dogs_per_booking = 51
    assert_not @space.valid?
    assert_includes @space.errors[:max_dogs_per_booking], "must be in 1..50"
  end

  test "should accept max_dogs_per_booking within valid range" do
    @space.max_dogs_per_booking = 1
    assert @space.valid?

    @space.max_dogs_per_booking = 25
    assert @space.valid?

    @space.max_dogs_per_booking = 50
    assert @space.valid?
  end

  test "should accept boolean values for visibility fields" do
    @space.other_dogs_visible_audible = true
    @space.other_pets_visible_audible = false
    @space.other_people_visible_audible = true
    assert @space.valid?
  end

  # Enum tests
  test "should have correct fencing_status enum values" do
    expected_values = ["fully_fenced", "partially_fenced", "not_fenced"]
    assert_equal expected_values.sort, Space.fencing_statuses.keys.sort
  end

  test "should have correct status enum values" do
    expected_values = ["active", "inactive"]
    assert_equal expected_values.sort, Space.statuses.keys.sort
  end

  test "should set default status to active" do
    space = Space.new
    assert_equal "active", space.status
  end

  test "should accept valid fencing_status values" do
    ["fully_fenced", "partially_fenced", "not_fenced"].each do |status|
      @space.fencing_status = status
      assert @space.valid?, "#{status} should be valid"
      assert_equal status, @space.fencing_status
    end
  end

  test "should accept valid status values" do
    ["active", "inactive"].each do |status|
      @space.status = status
      assert @space.valid?, "#{status} should be valid"
      assert_equal status, @space.status
    end
  end

  test "should provide enum helper methods" do
    @space.fencing_status = "fully_fenced"
    assert @space.fully_fenced?
    assert_not @space.partially_fenced?
    assert_not @space.not_fenced?

    @space.status = "active"
    assert @space.active?
    assert_not @space.inactive?
  end

  # Edge cases and boundary conditions
  test "should handle edge case zipcodes" do
    # Test minimum valid zipcode
    @space.zipcode = "00000"
    assert @space.valid?

    # Test maximum valid zipcode
    @space.zipcode = "99999-9999"
    assert @space.valid?
  end

  test "should handle decimal precision for price" do
    @space.price_per_dog = 999999.99
    assert @space.valid?

    @space.price_per_dog = 0.01
    assert @space.valid?
  end

  test "should handle various space size formats" do
    valid_sizes = ["500 sqft", "2 acres", "1000 sq ft", "0.5 acre", "Small yard"]
    valid_sizes.each do |size|
      @space.space_size = size
      assert @space.valid?, "#{size} should be valid"
    end
  end

  # Association tests
  test "should be destroyed when user is destroyed" do
    @space.save!
    user_id = @user.id
    space_id = @space.id

    assert_difference 'Space.count', -3 do
      @user.destroy
    end
    
    assert_nil Space.find_by(id: space_id)
  end

  test "should belong to correct user" do
    @space.save!
    assert_equal @user.id, @space.user_id
    assert_equal @user, @space.user
  end
end
