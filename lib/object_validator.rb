class ObjectValidator
  autoload :Version, 'object_validator/version'
  autoload :Base, 'object_validator/base'
  autoload :StringValidator, 'object_validator/string_validator'
  autoload :HashValidator, 'object_validator/hash_validator'

  def initialize
  end

  def errors
    @errors ||= reset_errors!
  end

  def validate_object(obj, **options)
    reset_errors!
    type = options[:type]
    validator = self.class.const_get(type.to_s.capitalize + 'Validator')
    validator.new(options).validate(obj, errors)
    errors.empty?
  end

  def validate_schema!(_, _)
  end

  def reset_errors!
    @errors = Hash.new { |h, k| h[k] = [] }
  end
end
