class HomeController < ApplicationController
  def index
    render file: Rails.root.join('dist', 'index.html')
  end
end
