get '/signup' do
  erb :'sessions/signup', layout: false
end

post '/signup' do
  #TODO: Use BCrypt Gem for Hashing
  @user = User.new({
    business_name: params[:business_name],
    admin_name: params[:admin_name],
    admin_surname: params[:admin_surname],
    email: params[:email],
    subscription_type: params[:subscription_type]
    })
  @user.password = params[:password]

  if @user.save!
    erb :'dashboard/index', :layout => :'dashboard/layout'
  else
    flash[:error] = 'L\'indirizzo e-mail che hai inserito è già presente nei nostri database.'
    redirect '/signup'
  end
end