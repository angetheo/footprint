get '/' do
  if authenticate?
    redirect '/dashboard'
  else
    erb :landing, layout: false
  end
end