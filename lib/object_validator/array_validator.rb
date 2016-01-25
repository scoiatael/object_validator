class ObjectValidator::ArrayValidator < ObjectValidator::Base
  def validate(obj, errors)
    super

    validate_instance_of!(Array)
    validate_items!
  end

  def validate_items!
    items = options[:items] || []
    items.each.with_index { |k, i| validate_item(k, i) }
  end

  def validate_item(item, index)
    new_obj = obj[index]
    return if new_obj.nil? && !options[:required]
    ObjectValidator.new.validate_object(new_obj, **item.merge(prefix: "#{prefix}.#{index}", errors: errors))
  end
end
