helpers do

  def authenticate?
    !!session[:user_id]
  end

  def current_user
    if authenticate?
      User.find(session[:user_id])
    end
  end

  def todos
    todos = []
    # SEO
    todos << "Footprint SEO ha bisogno dell'URL del tuo sito web per eseguire l'analisi. <a href='/dashboard?tab=seo'>Inseriscilo ora.</a>" if current_user.website_url.nil?
    # SOCIAL
    # WORDS
  end

end