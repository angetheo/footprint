helpers do

  def priority level
    level = level.to_i
    "<i class='fa fa-circle'></i> "*level + "<i class='fa fa-circle-o'></i> " * (5-level)
  end

  def formatter test
    test == "true" ? ['text-navy','fa-check'] : ['text-danger','fa-times']
  end

end