module DateFormatValidator
  def valid_date?(date)
    return if date.blank?

    begin
      Time.parse(date)
      true
    rescue ArgumentError
      false
    end
  end
end
