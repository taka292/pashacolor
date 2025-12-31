class PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: [ :show, :edit, :update, :destroy ]
  before_action :set_color_themes, only: [ :new, :edit ]

  def index
    @posts = current_user.posts.includes(:color_theme).recent
    
    # 色別フィルタリング
    if params[:color_theme_id].present?
      @posts = @posts.where(color_theme_id: params[:color_theme_id])
      @filtered_color_theme = ColorTheme.find(params[:color_theme_id])
    end
  end

  def show
  end

  def new
    @post = current_user.posts.build
  end

  def create
    @post = current_user.posts.build(post_params)

    if @post.save
      redirect_to @post, notice: "投稿を作成しました"
    else
      set_color_themes
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @post.update(post_params)
      redirect_to @post, notice: "投稿を更新しました"
    else
      set_color_themes
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
    redirect_to posts_path, notice: "投稿を削除しました"
  end

  private

  def set_post
    @post = current_user.posts.includes(:color_theme).find(params[:id])
  end

  def set_color_themes
    @color_themes = ColorTheme.active.ordered
  end

  def post_params
    params.require(:post).permit(:color_theme_id, :description, :latitude, :longitude, :location_name, :image)
  end
end
