class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken

  before_action :redirect_if_using_default_domain

  private

  def redirect_if_using_default_domain
    if request.host == "techput.onrender.com"
      render json: { message: "Redirecting to new domain" }, status: 301, location: "https://tech-put.com#{request.fullpath}"
    end
  end
end
