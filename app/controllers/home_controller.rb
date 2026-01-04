class HomeController < ApplicationController
  def index
    @today_theme = DailyTheme.today_theme(current_user) if user_signed_in?
  end
end
