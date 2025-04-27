class HomeController < ApplicationController
  def index
    render json: { message: 'Welcome to TechPut API!!' }, status: :ok
  end
end