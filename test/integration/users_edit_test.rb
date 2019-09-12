require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  def setup
    @user = users(:michael)
  end

  test "unsuccessful edit" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), params: { user: { name:  "",
                                              email: "foo@invalid",
                                              password:              "foo",
                                              password_confirmation: "bar" } }

    assert_template 'users/edit'
  end

  test "successful edit with friendly forwarding" do
  get edit_user_path(@user)                                                   # @userのユーザー編集ページを取得
  log_in_as(@user)                                                            # @userでログイン
  assert_redirected_to edit_user_path(@user)                                  # @userのユーザー編集ページへ移動する
  log_in_as(@user)                                                            # ログインする
  get edit_user_path(@user)                                                   # userIDを取得(michael)
  name  = "Foo Bar"                                                           # フォーム欄に値を入力する
  email = "foo@bar.com"
  patch user_path(@user), params: { user: { name: name,                       # 引数としてわざと失敗する値を持ったuserIDをpatchリクエストで送信（更新）する
                                            email: email,
                                            password:              "",
                                            password_confirmation: "" } }
  assert_not flash.empty?                                                     # エラー文が空じゃなければtrue
  assert_redirected_to @user                                                  # michaelのユーザーidページへ移動できたらtrue
  @user.reload
  assert_equal name,  @user.name                                              # DB内の名前と@userの名前が一致していていたらtrue
  assert_equal email, @user.email                                             # DB内のEmailと@userの名前が一致
end
end
