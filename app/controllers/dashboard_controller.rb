get '/dashboard' do
  if authenticate?

    #NAVIGATION
    @current_tab = !!params[:tab] ? params[:tab] : ""
    case @current_tab
    when ''
      erb :'dashboard/index', :layout => :'dashboard/layout'
    when 'seo'
      erb :'dashboard/seo', :layout => :'dashboard/layout'
    else
      erb :'dashboard/index', :layout => :'dashboard/layout'
    end

  else
    flash[:error] = "Accedi per visualizzare il contenuto."
    redirect '/login'
  end
end