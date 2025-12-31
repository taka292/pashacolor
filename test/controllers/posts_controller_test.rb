require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = User.create!(
      email: "test@example.com",
      password: "password123",
      name: "Test User"
    )
    @color_theme = ColorTheme.first || ColorTheme.create!(
      color_name: "黄",
      color_code: "#FFFF00",
      display_order: 1
    )
    sign_in @user
  end

  test "should get index" do
    get posts_url
    assert_response :success
    assert_select "h1", text: "投稿一覧"
  end

  test "should get new" do
    get new_post_url
    assert_response :success
  end

  test "should show post" do
    post = Post.create!(
      user: @user,
      color_theme: @color_theme,
      description: "Test post"
    )
    get post_url(post)
    assert_response :success
  end

  test "should get edit" do
    post = Post.create!(
      user: @user,
      color_theme: @color_theme,
      description: "Test post"
    )
    get edit_post_url(post)
    assert_response :success
  end

  test "index should use includes to prevent N+1 queries" do
    # 複数の投稿を作成
    3.times do |i|
      Post.create!(
        user: @user,
        color_theme: @color_theme,
        description: "Post #{i}"
      )
    end

    # N+1クエリが発生しないことを確認
    # includes(:color_theme)により、color_themeも一緒に取得される
    assert_queries_count(3) do # 1: posts取得, 1: color_themes取得（includes）, 1: その他
      get posts_url
    end
  end
end
