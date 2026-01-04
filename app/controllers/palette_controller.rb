require 'set'

class PaletteController < ApplicationController
  before_action :authenticate_user!

  def index
    # 全パレットを取得
    @palettes = ColorPalette.ordered

    # 各パレットの進捗状況を取得
    @palette_progresses = current_user.palette_progresses.index_by(&:color_palette_id)

    # 現在のアクティブパレットを取得
    @current_palette = ColorPalette.current_palette_for(current_user)

    # 現在のアクティブパレットの色を取得
    @color_themes = @current_palette.color_themes.active.ordered
    
    # ユーザーが投稿した色のIDを取得（重複なし）
    posted_color_ids = current_user.posts
                                    .joins(:color_theme)
                                    .distinct
                                    .pluck(:color_theme_id)
    
    # 投稿済み色のマップを作成（高速検索用）
    @posted_colors = Set.new(posted_color_ids)

    # パレット変更のリクエストがある場合
    if params[:palette_id].present?
      requested_palette = ColorPalette.find_by(id: params[:palette_id])
      if requested_palette && can_access_palette?(requested_palette)
        @current_palette = requested_palette
        @color_themes = @current_palette.color_themes.active.ordered
      end
    end
  end

  def select_palette
    palette = ColorPalette.find(params[:palette_id])
    if palette && can_access_palette?(palette)
      current_user.select_palette!(palette)
      redirect_to palette_path, notice: "#{palette.name}を選択しました"
    else
      redirect_to palette_path, alert: "このパレットは選択できません"
    end
  end

  private

  def can_access_palette?(palette)
    # 基本パレットは常にアクセス可能
    return true if palette.display_order == 1

    # 前のパレットが完了している場合のみアクセス可能
    prev_palette = ColorPalette.where('display_order < ?', palette.display_order).ordered.last
    return false if prev_palette.nil?

    prev_palette.completed_by?(current_user)
  end
end

