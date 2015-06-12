helpers do

  # IDEA: create a hash with all the names of the tests.

  def seo_analysis website
    report = Seoreport.find_by(user_id: current_user.id)
    html_doc = Nokogiri::HTML(open('http://'+website.gsub(' ','')))
    @check_hash = {}
    p "IN seo analysis"
    structure_check(html_doc, report)

    @check_hash
  end

    def structure_check html_doc, report

      # TITLE CHECK
      report.title = html_doc.css('title')[0].text
      if report.title.length <= 70
        @check_hash[:title_length] = "pass"
        report.points += 1
      end

      # META DESC CHECK
      report.meta_description = html_doc.at('meta[name="description"]').nil? ? "" : html_doc.at('meta[name="description"]')['content']
      if report.meta_description.length <= 160 && report.meta_description != ""
        @check_hash[:description_length] = "pass"
        report.points += 1
      end

      # RELEVANT KEYWORDS CHECK
      formatted_report = html_doc.at('body').text.strip.gsub(/\s+/, " ")
      words = {}

      formatted_report.split(' ').each do |word|
        word.downcase!
        words[word] ? words[word] += 1 : words[word] = 1
      end
      ['di','a','da','in','con','su','per','tra','fra','uno','una','un','dei','del','delle','della','degli','e','i','o','la','il','gli','al','alla','agli','=',':','-'].each { |k| words.delete k }
      report.body = Hash[words.sort_by { |k,v| -v }[0..4]].keys.join(', ')

      # RELEVANT TITLE CHECK
      if (report.body.split(', ')-report.title.gsub(',','').split(' ').map(&:downcase)).size <= 2
        @check_hash[:relevant_title] = "pass"
        report.points += 1
      end

      #HEADINGS CHECK

      report.save!
    end

    def speed_check website
    end

    def security_check website
    end

    def mobile_check website
    end

end