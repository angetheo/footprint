helpers do

  def authenticate?
    !!session[:user]
  end

  def current_user
    User.find(session[:user])
  end

end