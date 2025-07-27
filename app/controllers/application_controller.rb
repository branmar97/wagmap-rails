class ApplicationController < ActionController::API
  def authorize_request
    header = request.headers['Authorization']
    token = header.split.last if header
    begin
      decoded = decode_token(token)
      @current_user = User.find(decoded['user_id'])
    rescue ActiveRecord::RecordNotFound, JWT::DecodeError
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end

  private

  def decode_token(token)
    decoded = JWT.decode(token, Rails.application.secret_key_base)[0]
    HashWithIndifferentAccess.new decoded
  end
end