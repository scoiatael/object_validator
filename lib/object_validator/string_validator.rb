class ObjectValidator::StringValidator < ObjectValidator::Base
  ERRORS = {}
  ERRORS[:format] = 'It doesn\'t match with a given regular expression.'
  ERRORS[:blank] = 'It can\'t be blank.'
  ERRORS[:min_length] = ->(min_length) { "It is too short (less than #{min_length} characters)." }
  ERRORS[:max_length] = ->(max_length) { "It is too long (more than #{max_length} characters)." }

  def validate(obj, errors)
    super

    validate_instance_of!(String)
    validate_blank!
    validate_format!
    validate_length!
  end

  private

  def validate_blank!
    can_be_blank = constraints[:blank]
    return if can_be_blank

    report_error(ERRORS[:blank]) if obj.nil? || obj.empty?
  end

  def validate_format!
    format = constraints[:format]
    return if format.nil?

    report_error(ERRORS[:format]) unless obj =~ format
  end

  def validate_length!
    length_constraints = constraints[:length]
    return unless length_constraints.respond_to?(:[])

    min_length = length_constraints[:min_length]
    max_length = length_constraints[:max_length]

    report_error(ERRORS[:min_length][min_length]) if too_short(min_length)
    report_error(ERRORS[:max_length][max_length]) if too_long(max_length)
  end

  def too_short(min_length)
    !obj.is_a?(String) || obj.length < min_length
  end

  def too_long(max_length)
    !obj.is_a?(String) || obj.length > max_length
  end
end
