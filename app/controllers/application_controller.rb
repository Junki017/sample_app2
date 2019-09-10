class ApplicationController < ActionController::Base
protecte_from_forgery with :exception

  def hello
    render html: "hello, world!"
  end
end
