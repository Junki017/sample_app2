module SessionsHelper

  def log_in(user)
    session[:user_id] = user.id
  end

  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user
    cookies.permanent[:remember_token] = user.remember_token
  end

  def current_user?(user)
    user == current_user
  end

  def current_user
    if (user_id = session[:user_id])                                            # 一時的なセッションユーザーがいる場合処理を行い、user_idに代入
      @current_user ||= User.find_by(id: user_id)                               # 現在のユーザーがいればそのまま、いなければsessionユーザーidと同じidを持つユーザーをDBから探して@current_user（現在のログインユーザー）に代入
    elsif (user_id = cookies.signed[:user_id])                                  # user_idを暗号化した永続的なユーザーがいる（cookiesがある）場合処理を行い、user_idに代入
      user = User.find_by(id: user_id)                                          # 暗号化したユーザーidと同じユーザーidをもつユーザーをDBから探し、userに代入
      if user && user.authenticated?(cookies[:remember_token])                  # DBのユーザーがいるかつ、受け取った記憶トークンをハッシュ化した記憶ダイジェストを持つユーザーがいる場合処理を行う
        log_in user                                                             # 一致したユーザーでログインする
        @current_user = user                                                    # 現在のユーザーに一致したユーザーを設定
      end
    end
  end

  def logged_in?
    !current_user.nil?
  end

  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  def log_out
      forget(current_user)
      session.delete(:user_id)
      @current_user = nil
  end

  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  # アクセスしようとしたURLを覚えておく
  def store_location
    session[:forwarding_url] = request.original_url if request.get?              # :forwarding_urlキーにリクエスト先のURLを、GETリクエストが送られた時だけ代入
  end
end
