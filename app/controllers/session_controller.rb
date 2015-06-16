################################

get '/signup' do
  erb :'sessions/signup', layout: false
end

post '/signup' do
  @user = User.new({
    business_name: params[:business_name],
    admin_name: params[:admin_name].capitalize,
    admin_surname: params[:admin_surname].capitalize,
    email: params[:email],
    subscription_type: params[:subscription_type],
    password: params[:password],
    })

  if @user.save!
    session[:user_id] = @user.id
    erb :'dashboard/index', :layout => :'dashboard/layout'
  elsif User.find_by(email: params[:email]).length > 0
    flash[:error] = "L'indirizzo e-mail che hai inserito è già presente nei nostri database. Riprova."
    redirect '/signup'
  elsif params[:password] != params[:password_repeat]
    flash[:error] = "La password che hai indicato è diversa dal campo di controllo. Riprova."
    redirect '/signup'
  end
end

################################

get '/login' do
  erb :'sessions/login', layout: false
end

post '/login' do
  @user = User.find_by(email: params[:email])
  if @user && @user.password == params[:password]
    session[:user_id] = @user.id
    redirect '/dashboard'
  else
    flash[:error] = "I dati che hai inserito non sono corretti. Riprova."
    redirect '/login'
  end
end

################################

get '/logout' do
  session.clear
  redirect '/'
end