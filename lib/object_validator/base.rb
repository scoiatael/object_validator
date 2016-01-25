class ObjectValidator::Base
  ERRORS = {}
  ERRORS[:nil] = 'It can\'t be nil.'
  ERRORS[:instance_of] = ->(klass) { "It is not an instance of #{klass}." }
  ERRORS[:custom] = 'Custom validation (validate proc) failed.'
  DEFAULTS = {
    required: false,
    constraints: {},
    prefix: 'self',
    validate: ->(_) { true }
  }.freeze

  attr_reader :obj, :errors, :constraints, :required, :prefix, :custom_validate
  alias_method :required?, :required

  def initialize(**options)
    @options = DEFAULTS.merge(options)
    @constraints = @options[:constraints]
    @required = @options[:required]
    @prefix = @options[:prefix]
    @custom_validate = @options[:validate]
  end

  def validate(obj, errors)
    @errors = errors
    @obj = obj

    validate_nil!
    validate_custom!
  end

  protected

  def report_error(error)
    errors[prefix] << error if required?
  end

  def validate_instance_of!(klass)
    report_error(ERRORS[:instance_of][klass]) unless obj.is_a? klass
  end

  private

  def validate_nil!
    report_error(ERRORS[:nil]) if obj.nil?
  end

  def validate_custom!
    report_error(ERRORS[:custom]) if obj.nil? || !custom_validate.call(obj)
  end
end
