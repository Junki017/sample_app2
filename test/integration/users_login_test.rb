require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  # test "the truth" do
  #   assert true
  # end
  test "login with valid information followed by logout" do                     # ログインとログアウトのテストを行う
    # ログイン用
    get login_path                                                              # ログインURL(/login)のnewアクションを取得
    post login_path, params: { session: { email:     @user.email,               # ログインURL(/login)のcreateアクションへデータを送り、paramsでセッションハッシュのemailにmichaelの（有効な）email
                                          password: 'password' } }              # passwordに'password'を渡す 要はfixtureで定義したmichaelでログインするということ
    assert is_logged_in?                                                        # テストユーザーがログイン中ならtrue
    assert_redirected_to @user                                                  # rediret先が@user(fixtureのmichaelのid)正しければtrue
    follow_redirect!                                                            # @userのurlに移動
    assert_template 'users/show'                                                # users/showで描画されていればtrue
    assert_select 'a[href=?]', login_path, count: 0                             # login_path(/login)がhref=/loginというソースコードで存在しなければtrue(0だから)
    assert_select 'a[href=?]', logout_path                                      # logout_path(/logout)が存在すればtrue
    assert_select 'a[href=?]', user_path(@user)                                 # michaelのidを/user/:idとして受け取った値が存在すればtrue

    #ログアウト用
    delete logout_path                                                          # ログアウトリンクが消えたらtrue
    assert_not is_logged_in?                                                    # テストユーザーのセッションが空、ログインしていなければ（ログアウトできたら）true
    assert_redirected_to root_url

    follow_redirect!                                                            # リダイレクト先(root_url)にPOSTリクエストが送信ができたらtrue
    assert_select "a[href=?]", login_path                                       # login_path(/login)がhref=/loginというソースコードで存在していればtrue
    assert_select "a[href=?]", logout_path,      count: 0                       # href="/logout"が存在しなければ(0なら)true
    assert_select "a[href=?]", user_path(@user), count: 0                       # michaelのidを/user/:idとして受け取った値が存在しなければtrue
  end



  test "login with remembering" do
    log_in_as(@user, remember_me: '1')
    assert_not_empty cookies['remember_token'], assigns(:user).remember_token
  end

  test "login without remembering" do
    log_in_as(@user, remember_me: '1')
    delete logout_path
    log_in_as(@user, remember_me: '0')
    assert_empty cookies['remember_token']
  end
end
