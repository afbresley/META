require_relative '03_searchable'
require 'active_support/inflector'

# Phase IVa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key,
  )

  def model_class
    class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    defaults = {
      :foreign_key => "#{name}_id".to_sym,
      :class_name => name.to_s.camelcase,
      :primary_key => :id
    }

    defaults.keys.each do |key|
      self.send("#{key}=", options[key] || defaults[key])
    end
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    defaults = {
      :foreign_key => "#{ self_class_name }_id".downcase.to_sym,
      :class_name => name.to_s.capitalize.singularize,
      :primary_key => :id
    }

    defaults.keys.each do |key|
      self.send("#{key}=", options[key] || defaults[key])
    end
  end
end

module Associatable
  # Phase IVb
  def belongs_to(name, options = {})
    self.assoc_options[name] = BelongsToOptions.new(name, options)


    define_method(name) do

      options = self.class.assoc_options[name]
#      debugger
       options
        .model_class
        .where(options.primary_key => self.send(options.foreign_key))
        .first
    end

  end

  def has_many(name, options = {})
    self.assoc_options[name] = HasManyOptions.new(name, self.name, options)

    define_method(name) do

      options = self.class.assoc_options[name]
      options
       .model_class
       .where(options.foreign_key => self.send(options.primary_key))

    end
  end


  def assoc_options
    # Wait to implement this in Phase V. Modify `belongs_to`, too.
    @assoc_options ||= {}
    @assoc_options
  end
end

class SQLObject
  extend Associatable
end
