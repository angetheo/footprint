helpers do

  def priority level
    level = level.to_i
    "<i class='fa fa-circle'></i> "*level + "<i class='fa fa-circle-o'></i> " * (5-level)
  end

  def formatter test
    test == "true" ? ['text-navy','fa-check'] : ['text-danger','fa-times']
  end

  def tests report
    all_tests = report.attributes.map { |attr| attr[1]['pass'] if attr[1].is_a? Hash }
    tests = Hash.new.tap do |h|
      h[:pass]  = all_tests.count { |el| el == 'true' }
      h[:fail]  = all_tests.count { |el| el == 'false' }
      h[:total] = all_tests.count { |el| el != nil }
    end
  end

end