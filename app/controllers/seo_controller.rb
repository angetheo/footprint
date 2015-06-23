put '/:user_id/website' do

  # 0) URL NORMALIZATION
  normalized_uri = PostRank::URI.clean(params[:website_url])

  # 1) CHECK THE STATUS OF THE WEBSITE FIRST
  request = Typhoeus.get(normalized_uri, followlocation: true)
  case request.response_code
  when 404
    flash[:error] = "<h3>Oops!</h3> Non siamo riusciti a trovare la pagina. Controlla di aver digitato correttamente l'indirizzo e riprova."
    redirect '/dashboard?tab=seo'
  when 500..600
    flash[:error] = "<h3>Oops!</h3> Non riusciamo a raggiungere il server del sito da te indicato. Riprova tra poco."
    redirect '/dashboard?tab=seo'
  when 0
    flash[:error] = "<h3>Oops!</h3> Non siamo riusciti a raggiungere il sito per un errore indefinito. Controlla l'indirizzo e riprova."
    redirect '/dashboard?tab=seo'
  end

  # 2) ASSOCIATE THE WEBSITE WITH THE USER
  user = User.find(params[:user_id])
  user.website_url = PostRank::URI.clean(request.effective_url)
  user.save!

  # 3) CREATE A NEW REPORT IF IT DOESN'T EXIST
  seo_report = Seoreport.find_or_create_by(user_id: params[:user_id])
  seo_report.generate(PostRank::URI.clean(request.effective_url))

  redirect '/dashboard?tab=seo'
end

get '/dashboard/speedtest' do
  if request.xhr?
    @report = Seoreport.find_by(user_id: current_user.id)
    @report.speed_check(current_user) if @report.load_time.nil? && @report.total_page_size.empty?
    erb :'dashboard/_speed_test', layout: false
  end
end

get '/demoseo' do
  user = User.find(current_user.id)
  user.website_url = ""
  user.save!

  Seoreport.destroy_all

  redirect '/dashboard?tab=seo'
end