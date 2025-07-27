require "test_helper"

class SpacesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    @other_user = users(:two)
    @space = spaces(:one)
    @other_space = spaces(:two)
    @token = encode_token({ user_id: @user.id })
    @other_token = encode_token({ user_id: @other_user.id })
    
    @valid_attributes = {
      address1: "123 New Street",
      address2: "Unit 1",
      city: "New City",
      state: "NY",
      zipcode: "10001",
      fencing_status: "partially_fenced",
      space_size: "2000 sqft",
      max_dogs_per_booking: 8,
      price_per_dog: 20.00,
      other_dogs_visible_audible: true,
      other_pets_visible_audible: false,
      other_people_visible_audible: true
    }
    
    @invalid_attributes = {
      address1: nil,  # Missing required field
      city: "a" * 101,  # Too long
      state: "INVALID",  # Invalid format
      zipcode: "123",  # Invalid format
      max_dogs_per_booking: 0,  # Out of range
      price_per_dog: -5.00  # Negative price
    }
  end

  # Helper method for JWT token encoding
  def encode_token(payload)
    JWT.encode(payload, Rails.application.secret_key_base)
  end

  # Authentication tests
  test "should require authentication for all actions" do
    # Test index without auth
    get spaces_path, as: :json
    assert_response :unauthorized
    assert_equal "Unauthorized", JSON.parse(response.body)["error"]

    # Test create without auth
    post spaces_path, params: { space: @valid_attributes }, as: :json
    assert_response :unauthorized

    # Test show without auth
    get space_path(@space), as: :json
    assert_response :unauthorized

    # Test update without auth
    patch space_path(@space), params: { space: @valid_attributes }, as: :json
    assert_response :unauthorized

    # Test destroy without auth
    delete space_path(@space), as: :json
    assert_response :unauthorized
  end

  test "should reject invalid token" do
    get spaces_path, headers: { 'Authorization' => 'Bearer invalid_token' }, as: :json
    assert_response :unauthorized
  end

  test "should return empty array when user has no spaces" do
    # Create a user with no spaces
    user_without_spaces = User.create!(
      email: 'no_spaces@example.com',
      password: 'password123',
      first_name: 'No',
      last_name: 'Spaces',
      birthdate: Date.new(1990, 1, 1)
    )
    token = encode_token({ user_id: user_without_spaces.id })
    
    get spaces_path, headers: { 'Authorization' => "Bearer #{token}" }, as: :json
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert_equal [], json_response
  end

  # Show action tests
  test "should show space when user owns it" do
    get space_path(@space), headers: { 'Authorization' => "Bearer #{@token}" }, as: :json
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert_equal @space.id, json_response['id']
    assert_equal @space.address1, json_response['address1']
    assert_equal @space.price_per_dog.to_s, json_response['price_per_dog']
  end

  test "should not show space when user does not own it" do
    get space_path(@other_space), headers: { 'Authorization' => "Bearer #{@token}" }, as: :json
    assert_response :not_found
    
    json_response = JSON.parse(response.body)
    assert_equal "Space not found", json_response['error']
  end

  test "should return not found for non-existent space" do
    get space_path(99999), headers: { 'Authorization' => "Bearer #{@token}" }, as: :json
    assert_response :not_found
  end

  test "should not create space with invalid attributes" do
    assert_no_difference('Space.count') do
      post spaces_path,
           params: { space: @invalid_attributes },
           headers: { 'Authorization' => "Bearer #{@token}" },
           as: :json
    end
    
    assert_response :unprocessable_entity
    
    json_response = JSON.parse(response.body)
    assert json_response.has_key?('errors')
    assert json_response['errors'].is_a?(Array)
    assert json_response['errors'].length > 0
  end

  test "should not create space without required parameters" do
    assert_no_difference('Space.count') do
      post spaces_path,
           params: {},
           headers: { 'Authorization' => "Bearer #{@token}" },
           as: :json
    end
    
    assert_response :bad_request
  end

  # Update action tests
  test "should update space when user owns it" do
    update_attributes = { address1: "Updated Address", price_per_dog: 25.00 }
    
    patch space_path(@space),
          params: { space: update_attributes },
          headers: { 'Authorization' => "Bearer #{@token}" },
          as: :json
    
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert_equal "Updated Address", json_response['address1']
    assert_equal "25.0", json_response['price_per_dog']
    
    # Verify space was actually updated in database
    @space.reload
    assert_equal "Updated Address", @space.address1
    assert_equal 25.00, @space.price_per_dog
  end

  test "should not update space when user does not own it" do
    original_address = @other_space.address1
    
    patch space_path(@other_space),
          params: { space: { address1: "Hacked Address" } },
          headers: { 'Authorization' => "Bearer #{@token}" },
          as: :json
    
    assert_response :not_found
    
    # Verify space was not updated
    @other_space.reload
    assert_equal original_address, @other_space.address1
  end

  test "should not update space with invalid attributes" do
    original_address = @space.address1
    
    patch space_path(@space),
          params: { space: { address1: nil, city: "a" * 101 } },
          headers: { 'Authorization' => "Bearer #{@token}" },
          as: :json
    
    assert_response :unprocessable_entity
    
    json_response = JSON.parse(response.body)
    assert json_response.has_key?('errors')
    
    # Verify space was not updated
    @space.reload
    assert_equal original_address, @space.address1
  end

  # Destroy action tests
  test "should destroy space when user owns it" do
    space_to_delete = @user.spaces.create!(@valid_attributes)
    
    assert_difference('Space.count', -1) do
      delete space_path(space_to_delete),
             headers: { 'Authorization' => "Bearer #{@token}" },
             as: :json
    end
    
    assert_response :no_content
    assert_empty response.body
  end

  test "should not destroy space when user does not own it" do
    assert_no_difference('Space.count') do
      delete space_path(@other_space),
             headers: { 'Authorization' => "Bearer #{@token}" },
             as: :json
    end
    
    assert_response :not_found
  end

  test "should return not found when destroying non-existent space" do
    delete space_path(99999), headers: { 'Authorization' => "Bearer #{@token}" }, as: :json
    assert_response :not_found
  end

  # JSON response format tests
  test "should return properly formatted JSON for single space" do
    get space_path(@space), headers: { 'Authorization' => "Bearer #{@token}" }, as: :json
    assert_response :success
    
    json_response = JSON.parse(response.body)
    
    # Check all expected fields are present
    expected_fields = %w[id address1 address2 city state zipcode fencing_status 
                        space_size max_dogs_per_booking price_per_dog 
                        other_dogs_visible_audible other_pets_visible_audible 
                        other_people_visible_audible status created_at updated_at]
    
    expected_fields.each do |field|
      assert json_response.has_key?(field), "Missing field: #{field}"
    end
  end

  test "should return properly formatted JSON for space collection" do
    get spaces_path, headers: { 'Authorization' => "Bearer #{@token}" }, as: :json
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert_instance_of Array, json_response
    
    if json_response.any?
      # Check first space has all expected fields
      space = json_response.first
      expected_fields = %w[id address1 city state fencing_status price_per_dog]
      
      expected_fields.each do |field|
        assert space.has_key?(field), "Missing field in collection: #{field}"
      end
    end
  end

  # Content type tests
  test "should set correct content type for JSON responses" do
    get spaces_path, headers: { 'Authorization' => "Bearer #{@token}" }, as: :json
    assert_equal 'application/json; charset=utf-8', response.content_type
  end

  # Status enum tests
  test "should allow updating status" do
    patch space_path(@space),
          params: { space: { status: 'inactive' } },
          headers: { 'Authorization' => "Bearer #{@token}" },
          as: :json
    
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert_equal 'inactive', json_response['status']
    
    @space.reload
    assert @space.inactive?
  end
end
