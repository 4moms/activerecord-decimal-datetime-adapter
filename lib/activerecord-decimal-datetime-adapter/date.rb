# Mostly cribbed from ActiveRecord 3.1.3's active_record/attribute_methods/time_zone_conversion.rb

module ActiveRecordDecimalDatetimeAdapter
   module Date
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
           generated_attribute_methods.send(:define_method, attr_name) do
             @attributes_cache[attr_name] ||=
               begin
                 date = read_attribute(attr_name)
                 if date.is_a? Numeric and date.to_s =~ /^(\d{4})(\d{2})(\d{2})(?:\.0)?$/
                   DateTime.strptime(date.to_s.split('.')[0], '%Y%m%d')
                 else
                   nil
                 end
               end
           end
         else
           super
         end
       end

       def define_method_attribute=(attr_name)
         if create_decimal_date_attribute?(attr_name, columns_hash[attr_name])
           generated_attribute_methods.send(:define_method, "#{attr_name}=") do |new_date|
             decimal = new_date
             if decimal.respond_to?(:strftime)
               decimal = decimal.strftime('%Y%m%d').to_f
             end
             write_attribute(attr_name, decimal)
             @attributes_cache[attr_name] = new_date
           end
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

ActiveRecord::Base.send :include, ActiveRecordDecimalDatetimeAdapter::Date
