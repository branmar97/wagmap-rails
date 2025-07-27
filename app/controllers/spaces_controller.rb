class SpacesController < ApplicationController
  before_action :authorize_request
  before_action :set_space, only: [:show, :update, :destroy]

  def index
    @spaces = @current_user.spaces
  end

  def create
    @space = @current_user.spaces.build(space_params)
    if @space.save
      render :show, status: :created
    else
      render json: { errors: @space.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
  end

  def update
    if @space.update(space_params)
      render :show, status: :ok
    else
      render json: { errors: @space.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @space.destroy
    head :no_content
  end

  private

  def set_space
    begin
      @space = @current_user.spaces.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Space not found' }, status: :not_found
    end
  end

  def space_params
    params.require(:space).permit(
      :address1, :address2, :city, :state, :zipcode,
      :fencing_status, :space_size, :max_dogs_per_booking, :price_per_dog,
      :other_dogs_visible_audible, :other_pets_visible_audible, :other_people_visible_audible,
      :status
    )
  end
end
