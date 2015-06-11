get '/dashboard' do
  if authenticate?
    erb :'dashboard/index', :layout => :'dashboard/layout'
  else
    flash[:error] = "Accedi per visualizzare il contenuto."
    redirect '/login'
  end
end