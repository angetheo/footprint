get '/dashboard' do
  if authenticate?
    @report = Seoreport.find_by(user_id: current_user.id)

    # NAVIGATION
    @current_tab = !!params[:tab] ? params[:tab] : ""

    case @current_tab
    when ''
      erb :'dashboard/index', :layout => :'dashboard/layout'
    when 'seo'
      if current_user.website_url.nil? || current_user.website_url == ""
        erb :'dashboard/seo_starter', :layout => :'dashboard/layout'
      else
        erb :'dashboard/seo', :layout => :'dashboard/layout'
      end
    when 'ux'
      erb :'dashboard/ux', :layout => :'dashboard/layout'
    else
      erb :'dashboard/index', :layout => :'dashboard/layout'
    end
    # END NAVIGATION

  else
    flash[:error] = "Accedi per visualizzare il contenuto."
    redirect '/login'
  end
end

get '/profile/:user_id' do
  if authenticate? && current_user.id == params[:user_id].to_i
    erb :'dashboard/profile', :layout => :'dashboard/layout'
  else
    redirect '/dashboard'
  end
end