require 'set'

class PaletteController < ApplicationController
  before_action :authenticate_user!

  def index
    # 全12色の色相環を取得
    @color_themes = ColorTheme.active.ordered
    
    # ユーザーが投稿した色のIDを取得（重複なし）
    posted_color_ids = current_user.posts
                                    .joins(:color_theme)
                                    .distinct
                                    .pluck(:color_theme_id)
    
    # 投稿済み色のマップを作成（高速検索用）
    @posted_colors = Set.new(posted_color_ids)
  end
end

