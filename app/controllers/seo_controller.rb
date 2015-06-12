#### ADD THE WEBSITE FIRST ####

put '/:user_id/website' do
  user = User.find(params[:user_id])
  user.website_url = params[:website_url]
  user.save!

  # seo_analysis(params[:website_url])
  redirect '/dashboard?tab=seo'
end