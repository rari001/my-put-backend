class HomeController < ApplicationController
  def index
    # Reactのビルドされたindex.htmlを返す
    render file: 'public/index.html', layout: false
  end
end