#### ADD THE WEBSITE FIRST ####

put '/:user_id/website' do
  # CHECK THE STATUS OF THE WEBSITE FIRST
  request = Typhoeus.get(params[:website_url])

  case request.response_code
  when 404
    flash[:error] = "<h3>Oops!</h3> Non siamo riusciti a trovare la pagina. Controlla di aver digitato correttamente l'indirizzo e riprova."
    redirect '/dashboard?tab=seo'
  when 500..600
    flash[:error] = "<h3>Oops!</h3> Il sito da te digitato ha risposto con un errore del server. Riprova tra poco."
    redirect '/dashboard?tab=seo'
  when 0
    flash[:error] = "<h3>Oops!</h3> Non siamo riusciti a raggiungere il sito per un errore indefinito. Controlla l'indirizzo e riprova."
    redirect '/dashboard?tab=seo'
  end

  user = User.find(params[:user_id])
  user.website_url = params[:website_url]
  user.save!

  # CREATE A NEW REPORT IF IT DOESN'T EXIST
  if Seoreport.find_by(id: params[:user_id]).nil?
    Seoreport.create({
      user_id: params[:user_id]
      })
  end

  # ANALYSIS
  seo_analysis(params[:website_url])

  # STORE THE REPORT
  redirect '/dashboard?tab=seo'
end

get '/demoseo' do
  user = User.find(current_user.id)
  user.website_url = ""
  user.save!

  Seoreport.destroy_all

  redirect '/dashboard?tab=seo'
end