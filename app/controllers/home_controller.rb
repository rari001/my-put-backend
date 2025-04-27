class HomeController < ApplicationController
  def index
    # Reactのビルドされたindex.htmlを返す
    render file: Rails.root.join('dist', 'index.html'), layout: false
  end
end
