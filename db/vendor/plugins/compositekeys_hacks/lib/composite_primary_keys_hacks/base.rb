module CompositePrimaryKeys
  module ActiveRecord
    module Base
      module CompositeClassMethods
        
        def find_from_ids(ids, options)
          ids = ids.first if ids.last == nil
          conditions_option = " AND (#{sanitize_sql(options[:conditions])})" if options[:conditions]
          # if ids is just a flat list, then its size must = primary_key.length (one id per primary key, in order)
          # if ids is list of lists, then each inner list must follow rule above
          if ids.first.is_a? String
            # find '2,1' -> ids = ['2,1']
            # find '2,1;7,3' -> ids = ['2,1;7,3']
            ids = ids.first.split(ID_SET_SEP).map {|id_set| id_set.split(ID_SEP).to_composite_ids}
            # find '2,1;7,3' -> ids = [['2','1'],['7','3']], inner [] are CompositeIds
          end
          ids = [ids.to_composite_ids] if not ids.first.kind_of?(Array)
          ids.each do |id_set| 
            unless id_set.is_a?(Array)
              raise "Ids must be in an Array, instead received: #{id_set.inspect}"
            end
            unless id_set.length == primary_keys.length
              raise "#{id_set.inspect}: Incorrect number of primary keys for #{class_name}: #{primary_keys.inspect}"
            end
          end
          
          # Let keys = [:a, :b]
          # If ids = [[10, 50], [11, 51]], then :conditions => 
          #   "(#{table_name}.a, #{table_name}.b) IN ((10, 50), (11, 51))"
          
          conditions = ids.map do |id_set|
            [primary_keys, id_set].transpose.map do |key, id|
              col = columns_hash[key.to_s]
              #Do type cast before using directly in sql conditions to ensure the data is converted to sql format
              #For instance, date field should be converted from "dd/mm/yyyy" to appropriate sql format which would be "yyyy-mm-dd"(in MySQL case)
              type_casted_id = id.is_a?(ActiveRecord::Base) ? id : col.type_cast(id)
              val = quote_value(type_casted_id, col)  
			   
              "#{table_name}.#{key.to_s}=#{val}"
            end.join(" AND ")
          end.join(") OR (")
          options.update :conditions => "(#{conditions})#{conditions_option}"
          result = find_every(options)
              
          if result.size == ids.size
            ids.size == 1 ? result[0] : result
          else
            raise ::ActiveRecord::RecordNotFound, "Couldn't find all #{name.pluralize} with IDs (#{ids.inspect})#{conditions}"
          end
        end
        
        alias_method :find_from_ids_without_nil_check, :find_from_ids
        def find_from_ids(ids, options)
          return if ids.nil? || (ids.kind_of?(Array) && (ids.flatten == [nil] || ids.flatten == [""]))
          find_from_ids_without_nil_check(ids, options)
        end

        
        def exists?(id_or_conditions)
          begin
            obj = find(ids) #rescue false
            !obj.nil? and obj.is_a?(self)
          rescue
            ar_exists?(id_or_conditions) rescue false
          end
        end

        #The following method was copied from ActiveRecord::Base, bcos somehow we are not able to call the
        #original method which is 2 levels above...
        def ar_exists?(id_or_conditions)
          connection.select_all(
            construct_finder_sql(
              :select     => "#{quoted_table_name}.#{primary_key}",
              :conditions => expand_id_conditions(id_or_conditions),
              :limit      => 1
            ),
            "#{name} Exists"
          ).size > 0
        end

      end

      module CompositeInstanceMethods

        # Reloads the attributes of this object from the database.
        # The optional options argument is passed to find when reloading so you
        # may do e.g. record.reload(:lock => true) to reload the same record with
        # an exclusive row lock.
        def reload(options = {})
          clear_aggregation_cache
          clear_association_cache
          @attributes.update(self.class.find(self.id, options).instance_variable_get('@attributes'))
          @attributes_cache = {}
          self
        end

        def quoted_id #:nodoc:
          [self.class.primary_keys, ids.flatten].
            transpose.
            map {|attr_name,id| quote_value(id, column_for_attribute(attr_name))}.
            to_composite_ids
        end
                
        alias_method :update_without_lock, :update_without_callbacks
        def update_without_callbacks #:nodoc:
          return update_without_lock unless locking_enabled?
          where_clause_terms = [self.class.primary_key, quoted_id].transpose.map do |pair| 
            "(#{connection.quote_column_name(pair[0])} = #{pair[1]})"
          end
          where_clause = where_clause_terms.join(" AND ")
          lock_col = self.class.locking_column
          previous_value = send(lock_col)
          send(lock_col + '=', previous_value + 1)

          affected_rows = connection.update(<<-end_sql, "#{self.class.name} Update with optimistic locking")
                        UPDATE #{self.class.table_name}
                        SET #{quoted_comma_pair_list(connection, attributes_with_quotes(false))}
                        WHERE #{where_clause}
                        AND #{self.class.quoted_locking_column} = #{quote_value(previous_value)}
          end_sql
                    
          unless affected_rows == 1
            raise ::ActiveRecord::StaleObjectError, "Attempted to update a stale object"
          end

          return true
        end
                
        def attributes=(new_attributes, guard_protected_attributes = true)
          return if new_attributes.nil?
          attributes = new_attributes.dup
          attributes.stringify_keys!

          multi_parameter_attributes = []
          attributes = remove_attributes_protected_from_mass_assignment(attributes) if guard_protected_attributes
          attributes.each do |k, v|
            if k.include?("(") 
              multi_parameter_attributes << [ k, v ]
            else
              if k.include?(",") && v.kind_of?(Array)
                t = k.split(",")
                t.size.times{|i|
                  send(t[i] + "=", v[i])
                }
              else
                send(k + "=", v)
              end
            end

            assign_multiparameter_attributes(multi_parameter_attributes)
          end
        end
        # Updates the attribute identified by <tt>attr_name</tt> with the specified +value+.
        # (Alias for the protected write_attribute method).
        def []=(attr_name, value)
          if attr_name.is_a?(String) and attr_name != attr_name.split(ID_SEP).first
            attr_name = attr_name.split(ID_SEP)
          end

          if attr_name.is_a? Array
            value = value.split(ID_SEP) if value.is_a? String
            #When we build has_one association, it raises error due to composite key because master doesn't have pk values in new mode.
            #so, value will be nil and need to convert to nil array for the composite key
            #eg: sales_order.build_sales_invoice (code snippit from sales_invoice.rb).
            value = Array.new(attr_name.length) if value.nil?
            unless value.length == attr_name.length
              raise "Number of attr_names and values do not match"
            end
            #breakpoint
            [attr_name, value].transpose.map {|name,val| write_attribute(name.to_s, val)}
          else
            write_attribute(attr_name, value)
          end
        end
      end
    end
  end
end
