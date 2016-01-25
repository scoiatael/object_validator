class ObjectValidator::HashValidator < ObjectValidator::Base
  ERRORS = {}
  ERRORS[:empty] = 'It can\'t be empty.'

  def validate(obj, errors)
    super

    validate_instance_of!(Hash)
    validate_empty!
    validate_keys!
  end

  private

  def validate_empty!
    can_be_empty = constraints[:empty]
    return if can_be_empty

    report_error(ERRORS[:empty]) if obj.nil? || obj.empty?
  end

  def validate_keys!
    keys = options[:keys] || []
    keys.each { |k| validate_key(k) }
  end

  def validate_key(k)
    key = k[:key]
    options = k
    new_obj = obj[key]
    return if new_obj.nil? && !options[:required]
    ObjectValidator.new.validate_object(new_obj, **options.merge(prefix: "#{prefix}.#{key}", errors: errors))
  end
end
