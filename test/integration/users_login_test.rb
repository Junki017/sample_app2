require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  # test "the truth" do
  #   assert true
  # end
  test "login with valid information followed by logout" do
   get login_path
   post login_path, params: { session: { email:    @user.email,
                                         password: 'password' } }
   assert is_logged_in?
   assert_redirected_to @user
   follow_redirect!
   assert_template 'users/show'
   assert_select "a[href=?]", login_path, count: 0
   assert_select "a[href=?]", logout_path
   assert_select "a[href=?]", user_path(@user)

    #ログアウト用
    delete logout_path                                                          # ログアウトリンクが消えたらtrue
    assert_not is_logged_in?                                                    # テストユーザーのセッションが空、ログインしていなければ（ログアウトできたら）true
    assert_redirected_to root_url                                               # Homeへ飛べたらtrue
    follow_redirect!                                                            # リダイレクト先(root_url)にPOSTリクエストが送信ができたらtrue
    assert_select "a[href=?]", login_path                                       # login_path(/login)がhref=/loginというソースコードで存在していればtrue
    assert_select "a[href=?]", logout_path,      count: 0                       # href="/logout"が存在しなければ(0なら)true
    assert_select "a[href=?]", user_path(@user), count: 0
  end
end
