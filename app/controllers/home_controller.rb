class HomeController < ApplicationController
  def index
    @today_theme = DailyTheme.today_theme
  end
end
