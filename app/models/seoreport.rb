class Seoreport < ActiveRecord::Base

  attr_reader :user

  def initialize(args = {})
    super
    @user = User.find_by(id: self.user_id)
  end


  def generate website_url
    html_doc = Nokogiri::HTML(open('http://'+website_url.gsub(' ','')))
    html_doc_with_script = html_doc.dup
    html_doc.xpath("//script").remove

    structure_check(html_doc, html_doc_with_script)
  end

  ###################
  # STRUCTURE TESTS #
  ###################

  def structure_check html_doc, html_doc_with_script

    # TITLE LENGTH TEST
    page_title = html_doc.css('title')[0].text
    self.title = Hash.new.tap do |test_hash|
      test_hash[:page_title]  = page_title
      test_hash[:length]      = page_title.size
      test_hash[:title]       = 'Titolo della pagina'
      test_hash[:subtitle]    = title.size <= 70 ? 'La lunghezza del titolo è in linea con i requisiti di molti motori di ricerca.' : 'Il titolo è troppo lungo e potrebbe essere troncato nei risultati di ricerca.'
      test_hash[:description] = 'Molti motori di ricerca troncano la lunghezza del titolo a 70 caratteri o meno. Riducendo la lunghezza del titolo permetti agli utenti di vedere il titolo intero e di comprendere il contenuto del sito in base ai risultati organici di ricerca.'
      test_hash[:priority]    = 2
      test_hash[:pass]        = page_title.size <= 70
    end
    self.points += 1 if page_title.size <= 70

    # META DESCRIPTION LENGTH TEST
    meta_description = html_doc.at('meta[name="description"]').nil? ? "" : html_doc.at('meta[name="description"]')['content']
    self.meta_description = Hash.new.tap do |test_hash|
      test_hash[:page_meta_description]  = meta_description
      test_hash[:length]      = meta_description.size
      test_hash[:title]       = 'Descrizione della pagina'
      test_hash[:subtitle]    = if meta_description == ""
                                  'Non abbiamo trovato una descrizione del tuo sito. Aggiungine una al più presto.'
                                elsif meta_description.size <= 160
                                  'La lunghezza della descrizione è in linea con i requisiti di molti motori di ricerca.'
                                else
                                  'La descrizione è troppo lunga e potrebbe essere troncato nei risultati di ricerca.'
                                end
      test_hash[:description] = 'La descrizione del sito può essere inserita tramite i <code>meta</code> tags. E\' molto importante perché permette ai motori di ricerca di comprendere il contenuto del sito e fornisce un\'anteprima agli utenti che visualizzano il tuo sito nei risultati organici di ricerca.'
      test_hash[:priority]    = 2
      test_hash[:pass]        = meta_description.size <= 160
    end
    self.points += 1 if meta_description.size <= 160

    # RELEVANT KEYWORDS
    formatted_html_doc = html_doc.at('body').text.strip.gsub(/\s+/, " ")
    words = {}
    formatted_html_doc.split(' ').each do |word|
      word.downcase!
      words[word] ? words[word] += 1 : words[word] = 1
    end
    ['se','come','che','di','a','da','in','con','su','per','tra','fra','uno','una','un','dei','del','delle','della','degli','e','ed','è','i','o','la','le','il','gli','al','alla','agli','si','no','non','tuoi','tuo','nel','nella','negli','nelle',' ','=',':','-','//','+','"','""','{','}','"";','==','condividi','altra','altro','commenta','commenti','tutto','tutte','tutti'].each { |k| words.delete k }
    self.keywords = Hash[words.sort_by { |k,v| -v }[0..4]].keys.join(', ')

    # RELEVANT KEYWORDS IN TITLE AND DESCRIPTION CHECK
    keywords = self.keywords.split(', ')
    title_words = self.title['page_title'].gsub(/\W/,' ').split(' ').map(&:downcase)
    meta_description_words    = self.meta_description['page_meta_description'].to_s.gsub(/\W/,'').split(' ').map(&:downcase)
    remaining_words = (keywords - title_words - meta_description_words)
    self.relevant_keywords    = Hash.new.tap do |test_hash|
      test_hash[:remaining_keywords] = remaining_words.join(' - ')
      test_hash[:title]       = 'Utilizzo delle parole chiave'
      test_hash[:subtitle]    = remaining_words.size <= 2 ? "Utilizzi la maggior parte delle parole chiave nel titolo e nella descrizione" : "Non stai utilizzando le parole chiave nel titolo e nella descrizione"
      test_hash[:description] = "Il titolo e la descrizione della tua pagina dovrebbero riflettere i contenuti del tuo sito. Utilizzando le parole chiave contenute nella tua pagina in titolo e descrizione, aiuti i motori di ricerca a categorizzare correttamente i contenuti e a mostrare il tuo sito nei risultati di ricerca di persone interessate."
      test_hash[:priority] = 4
      test_hash[:pass] = remaining_words.size <= 2
    end


    #ROBOTS CHECK
    request = Typhoeus.get(@user.website_url+'/robots.txt')
    if request.response_code != 404
      self.robots = true
      self.points += 2
    else
      self.robots = false
    end

    #SITEMAP XML CHECK
    # Basically we have to check whether there is or not an xml (or xml.gz) file
    # in the root directory of the website. The problem is that the only way I
    # know is to send http requests to a specific URL and check the response.

    request1 = Typhoeus.get(@user.website_url+'/sitemap.xml')
    request2 = Typhoeus.get(@user.website_url+'/sitemap.xml.gz')
    if request1.response_code != 404 && request2.response_code != 404
      self.sitemap = true
      self.points += 2
    else
      self.sitemap = false
    end

    #IMG ALT TAG CHECK
    img_tags = html_doc.css('img')
    alt_tags = html_doc.css('img').map{ |i| i['alt']}
    self.alt_tags = alt_tags.size/img_tags.size
    if self.alt_tags >= 0.80
      self.points += 1
    end

    #INLINE CSS STYLING
    inline_style = html_doc.css "[style]"
    self.inline_style = inline_style.size
    if self.inline_style <= 5
      self.points += 1
    end

    #FAVICON CHECK
    default_favicon_request = Typhoeus.get(@user.website_url+'/favicon.ico')
    link_rel_icon_elements = html_doc.xpath('//link[contains(@rel,"icon")]')
    custom_favicon_url = link_rel_icon_elements.empty? ? nil : link_rel_icon_elements.first['href']
    if custom_favicon_url != nil
      if Typhoeus.get(custom_favicon_url).response_code == 200
        self.favicon_url = custom_favicon_url
        self.points += 1
      elsif Typhoeus.get(@user.website_url+custom_favicon_url).response_code == 200
        self.favicon_url = 'http://'+@user.website_url+custom_favicon_url
        self.points += 1
      end
    elsif default_favicon_request.response_code == 200
      self.favicon_url = @user.website_url+'/favicon.ico'
      self.points += 1
    end

    #DEPRECATED HTML TAGS CHECK
    deprecated_tags = ['applet','basefont','center','dir','embed','font','isindex','listing','menu','plaintext','s','strike','u','xmp']
    used_tags = deprecated_tags.find_all { |deprecated_tag| html_doc.css(deprecated_tag).size > 0 }
    if used_tags.empty?
      self.points += 1
    else
      self.deprecated_tags = deprecated_tags.join(' - ')
    end


    #BROKEN LINKS CHECK
    # links_status = {}
    # all_links = html_doc.css('a').map { |link| link['href'] }

    #GOOGLE ANALYTICS CHECK
    if html_doc_with_script.xpath('//script[contains(text(), "GoogleAnalyticsObject")]')
      self.google_analytics = true
      self.points += 3
    end

    #GOOGLE RANKING
    self.google_rank = PageRankr.rank(@user.website_url, :google)[:google].nil? ? 0 : PageRankr.rank(@user.website_url, :google)[:google]
    self.points += self.google_rank/3

    #GOOGLE INDEXING
    self.google_index = PageRankr.index(@user.website_url, :google)[:google].nil? ? 0 : PageRankr.index(@user.website_url, :google)[:google]
    self.points += 1 if self.google_index > 5

    #GOOGLE BACKLINKS
    self.google_backlinks = PageRankr.backlinks(@user.website_url, :google)[:google].nil? ? 0 : PageRankr.index(@user.website_url, :google)[:google]
    self.points += 1 if self.google_backlinks > 50

    self.save!

    p self
  end

end
