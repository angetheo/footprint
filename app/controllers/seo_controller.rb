put '/:user_id/website' do

  # 1) CHECK THE STATUS OF THE WEBSITE FIRST
  request = Typhoeus.get(params[:website_url])
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
  user.website_url = params[:website_url]
  user.save!

  # 3) CREATE A NEW REPORT IF IT DOESN'T EXIST
  seo_report = Seoreport.find_or_create_by(user_id: params[:user_id])
  seo_report.generate(params[:website_url])

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