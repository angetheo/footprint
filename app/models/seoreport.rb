class Seoreport < ActiveRecord::Base

  attr_accessor :check_hash
  attr_reader :user

  def initialize(args = {})
    super
    @check_hash = {}
    @user = User.find_by(id: self.user_id)
  end


  def generate website_url
    html_doc = Nokogiri::HTML(open('http://'+website_url.gsub(' ','')))
    html_doc.xpath("//script").remove

    structure_check(html_doc)
  end

  ###################
  # STRUCTURE TESTS #
  ###################

  def structure_check html_doc

    # TITLE LENGTH TEST
    self.title = html_doc.css('title')[0].text
    if self.title.length <= 70
      self.points += 1
      @check_hash[:title_length_test] = 'pass'
    end

    # META DESCRIPTION LENGTH TEST
    self.meta_description = html_doc.at('meta[name="description"]').nil? ? "" : html_doc.at('meta[name="description"]')['content']
    if self.meta_description.length <= 160 && self.meta_description != ""
      self.points += 1
      @check_hash[:meta_description_length] = 'pass'
    end

    # RELEVANT KEYWORDS CHECK
    formatted_html_doc = html_doc.at('body').text.strip.gsub(/\s+/, " ")
    words = {}

    formatted_html_doc.split(' ').each do |word|
      word.downcase!
      words[word] ? words[word] += 1 : words[word] = 1
    end

    ['se','come','che','di','a','da','in','con','su','per','tra','fra','uno','una','un','dei','del','delle','della','degli','e','ed','è','i','o','la','le','il','gli','al','alla','agli','si','no','non','tuoi','tuo','nel','nella','negli','nelle',' ','=',':','-','//','+','"','""','{','}','"";','=='].each { |k| words.delete k }
    self.body = Hash[words.sort_by { |k,v| -v }[0..4]].keys.join(', ')

    # RELEVANT TITLE CHECK
    keywords = self.body.split(', ')
    title_words = self.title.gsub(',','').split(' ').map(&:downcase)
    if (keywords-title_words).size <= keywords.size/3
      @check_hash[:relevant_title] = 'pass'
      self.points += 1
    end

    #ROBOTS CHECK
    request = Typhoeus.get(@user.website_url+'/robots.txt')
    if request.response_code != 404
      self.robots = true
      self.points += 1
      @check_hash[:robots] = 'pass'
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
      self.points += 1
      @check_hash[:sitemap] = 'pass'
    else
      self.sitemap = false
    end

    #IMG ALT TAG CHECK
    img_tags = html_doc.css('img')
    alt_tags = html_doc.css('img').map{ |i| i['alt']}
    self.alt_tags = alt_tags.size/img_tags.size
    if self.alt_tags >= 0.80
      self.points += 1
      @check_hash[:alt_tags] = 'pass'
    end

    #INLINE CSS STYLING
    inline_style = html_doc.css "[style]"
    p inline_style.size
    self.inline_style = inline_style.size
    if self.inline_style <= 5
      self.points += 1
      @check_hash[:inline_style] = 'pass'
    end

    #GOOGLE RANKING
    self.google_rank = PageRankr.rank(@user.website_url, :google)[:google].nil? ? 0 : PageRankr.rank(@user.website_url, :google)[:google]
    self.points += self.google_rank

    #GOOGLE INDEXING
    self.google_index = PageRankr.index(@user.website_url, :google)[:google].nil? ? 0 : PageRankr.index(@user.website_url, :google)[:google]
    self.points += 1 if self.google_index > 5

    self.save!
  end

end
