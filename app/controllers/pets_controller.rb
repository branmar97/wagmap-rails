class PetsController < ApplicationController
  before_action :authorize_request
  before_action :set_pet, only: [:show, :update, :destroy]

  def index
    @pets = @current_user.pets
  end

  def create
    @pet = @current_user.pets.build(pet_params)
    if @pet.save
      render :show, status: :created
    else
      render json: { errors: @pet.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
  end

  def update
    if @pet.update(pet_params)
      render json: @pet, status: :ok
    else
      render json: { errors: @pet.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @pet.destroy
    head :no_content
  end

  private

  def set_pet
    begin
      @pet = @current_user.pets.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Pet not found' }, status: :not_found
    end
  end

  def pet_params
    params.require(:pet).permit(
      :name, :primary_breed_id, :secondary_breed_id, :birthdate, :user_id, :sex, :description, :health, 
      colors: [], compatibilities: []
    )
  end
end
