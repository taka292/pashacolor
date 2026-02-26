class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @today_theme = DailyTheme.today_theme(current_user)
  end
end
