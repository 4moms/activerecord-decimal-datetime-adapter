module ActiveRecordDecimalDatetimeAdapter
   module Time
     extend ActiveSupport::Concern

     included do
       class_attribute :decimal_time_attributes, :instance_writer => false
       self.decimal_time_attributes = true

       class_attribute :extra_decimal_time_attributes, :instance_writer => false
       self.extra_decimal_time_attributes = []

       class_attribute :skip_decimal_time_attributes, :instance_writer => false
       self.skip_decimal_time_attributes = []
     end

     module ClassMethods
       protected

       def define_method_attribute(attr_name)
         if create_decimal_time_attribute?(attr_name, columns_hash[attr_name])
           generated_attribute_methods.send(:define_method, attr_name) do
             @attributes_cache[attr_name] ||=
               begin
                 time = read_attribute(attr_name)
                 if time.is_a? Numeric
                   stringy = Kernel.sprintf("%08d", time.to_i)
                   if stringy =~ /^(\d{2})(\d{2})(\d{2})(\d{2})(?:\.0)?$/
                     time = DateTime.strptime(stringy[0,6], '%H%M%S')
                     time += (stringy[6,2].to_f / (86_400 * 100))
                   end
                 end
                 time
               rescue
                 nil
               end
           end
         else
           super
         end
       end

       def define_method_attribute=(attr_name)
         if create_decimal_time_attribute?(attr_name, columns_hash[attr_name])
           generated_attribute_methods.send(:define_method, "#{attr_name}=") do |new_time|
             begin
               decimal = new_time
               if decimal.respond_to?(:strftime)
                 decimal = decimal.strftime('%H%M%S%2N').to_f
               end
               write_attribute(attr_name, decimal)
               @attributes_cache[attr_name] = new_time
             rescue
               nil
             end
           end
         else
           super
         end
       end

       private
       def create_decimal_time_attribute?(name, column)
         return false unless decimal_time_attributes
         return false unless name =~ /time$/i  || self.extra_decimal_time_attributes.include?(name.to_sym)
         return false if self.skip_decimal_time_attributes.include?(name.to_sym)
         return false if column.type != :integer
         true
       end
     end
   end
end

ActiveRecord::Base.send :include, ActiveRecordDecimalDatetimeAdapter::Time
