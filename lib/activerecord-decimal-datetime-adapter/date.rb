# Mostly cribbed from ActiveRecord 3.1.3's active_record/attribute_methods/time_zone_conversion.rb
require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/object/inclusion'

module ActiveRecord
  module AttributeMethods
    module DecimalDate
      extend ActiveSupport::Concern

      included do
        cattr_accessor :decimal_date_attributes, :instance_writer => false
        self.decimal_date_attributes = true

        class_attribute :extra_decimal_date_attributes, :instance_writer => false
        self.extra_decimal_date_attributes = []

        class_attribute :skip_decimal_date_attributes, :instance_writer => false
        self.skip_decimal_date_attributes = []
      end

      module ClassMethods
        protected

        def define_method_attribute(attr_name)
          if create_decimal_date_attribute?(attr_name, columns_hash[attr_name])
            method_body, line = <<-FUNCTION, __LINE__ + 1
              def _#{attr_name}
                @attributes_cache['#{attr_name}'] ||=
                  begin
                    original = _read_attribute('#{attr_name}')
                    date = original
                    if date.is_a? Numeric and date.to_s =~ /^(\\d{4})(\\d{2})(\\d{2})/
                      date = Time.zone.parse([$1,$2,$3].join("-"))
                    end
                    date
                  rescue
                    original
                  end
              end
              alias #{attr_name} _#{attr_name}
            FUNCTION
            generated_attribute_methods.module_eval(method_body, __FILE__, line)
          else
            super
          end
        end

        def define_method_attribute=(attr_name)
          if create_decimal_date_attribute?(attr_name, columns_hash[attr_name])
            method_body, line = <<-FUNCTION, __LINE__ + 1
              def _#{attr_name}=(original)
                date = original
                date = date.strftime('%Y%m%d').to_i if date.acts_like?(:date)
                write_attribute(:#{attr_name}, date)
                @attributes_cache['#{attr_name}'] = original
              end
            FUNCTION
            generated_attribute_methods.module_eval(method_body, __FILE__, line)
          else
            super
          end
        end

        private
        def create_decimal_date_attribute?(name, column)
          return false unless decimal_date_attributes
          return false unless name =~ /date$/i  || self.extra_decimal_date_attributes.include?(name.to_sym)
          return false if self.skip_decimal_date_attributes.include?(name.to_sym)
          return false if column.type != :integer
          true
        end
      end
    end
  end
end
