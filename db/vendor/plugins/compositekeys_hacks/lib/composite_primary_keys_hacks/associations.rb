module Associations
  module HasManyAssociation
    def delete_records(records)
      if @reflection.options[:dependent]
        records.each { |r| r.destroy }
      else
        field_names = @reflection.primary_key_name.to_s.split(',')
        field_names.collect! {|n| n + " = NULL"}
        records.each do |r|
          where_class = nil
		  
          if r.primary_keys.kind_of?(Array)
            where_class = [@reflection.klass.primary_key, r.quoted_id].transpose.map {|pair| "(#{pair[0]} = #{pair[1]})"}.join(" AND ")
          else
            where_class = @reflection.klass.primary_key.to_s + ' = ' +  r.quoted_id.to_s
          end
		  
          @reflection.klass.update_all(  field_names.join(',') , where_class)
        end
      end
    end

  end
end

module ActiveRecord
  module Associations
    module ClassMethods
      def has_one(association_id, options = {})
        if options[:through]
          reflection = create_has_one_through_reflection(association_id, options)
          association_accessor_methods(reflection, ActiveRecord::Associations::HasOneThroughAssociation)
        else
          reflection = create_has_one_reflection(association_id, options)

          ivar = "@#{reflection.name}"

          method_name = "has_one_after_save_for_#{reflection.name}".to_sym
          define_method(method_name) do
            association = instance_variable_get("#{ivar}") if instance_variable_defined?("#{ivar}")

            if !association.nil? && (new_record? || association.new_record? || association["#{reflection.primary_key_name}"] != id)
              association["#{reflection.primary_key_name}"] = id.to_s
              association.save(true)
            end
          end
          after_save method_name

          add_single_associated_validation_callbacks(reflection.name) if options[:validate] == true
          association_accessor_methods(reflection, HasOneAssociation)
          association_constructor_method(:build,  reflection, HasOneAssociation)
          association_constructor_method(:create, reflection, HasOneAssociation)

          configure_dependency_for_has_one(reflection)
        end
      end
      
      def belongs_to(association_id, options = {})
        reflection = create_belongs_to_reflection(association_id, options)

        ivar = "@#{reflection.name}"

        if reflection.options[:polymorphic]
          association_accessor_methods(reflection, BelongsToPolymorphicAssociation)

          method_name = "polymorphic_belongs_to_before_save_for_#{reflection.name}".to_sym
          define_method(method_name) do
            association = instance_variable_get("#{ivar}") if instance_variable_defined?("#{ivar}")

            if association && association.target
              if association.new_record?
                association.save(true)
              end

              if association.updated?
                self["#{reflection.primary_key_name}"] = association.id.to_s
                self["#{reflection.options[:foreign_type]}"] = association.class.base_class.name.to_s
              end
            end
          end
          before_save method_name
        else
          association_accessor_methods(reflection, BelongsToAssociation)
          association_constructor_method(:build,  reflection, BelongsToAssociation)
          association_constructor_method(:create, reflection, BelongsToAssociation)

          method_name = "belongs_to_before_save_for_#{reflection.name}".to_sym
          define_method(method_name) do
            association = instance_variable_get("#{ivar}") if instance_variable_defined?("#{ivar}")

            if !association.nil?
              if association.new_record?
                association.save(true)
              end

              if association.updated?
                self["#{reflection.primary_key_name}"] = association.id.to_s
              end
            end
          end
          before_save method_name
        end

        # Create the callbacks to update counter cache
        if options[:counter_cache]
          cache_column = options[:counter_cache] == true ?
            "#{self.to_s.underscore.pluralize}_count" :
            options[:counter_cache]

          method_name = "belongs_to_counter_cache_after_create_for_#{reflection.name}".to_sym
          define_method(method_name) do
            association = send("#{reflection.name}")
            association.class.increment_counter("#{cache_column}", send("#{reflection.primary_key_name}")) unless association.nil?
          end
          after_create method_name

          method_name = "belongs_to_counter_cache_before_destroy_for_#{reflection.name}".to_sym
          define_method(method_name) do
            association = send("#{reflection.name}")
            association.class.decrement_counter("#{cache_column}", send("#{reflection.primary_key_name}")) unless association.nil?
          end
          before_destroy method_name

          module_eval(
            "#{reflection.class_name}.send(:attr_readonly,\"#{cache_column}\".intern) if defined?(#{reflection.class_name}) && #{reflection.class_name}.respond_to?(:attr_readonly)"
          )
        end

        configure_dependency_for_belongs_to(reflection)
      end

      def construct_finder_sql_for_association_limiting(options, join_dependency)
        scope       = scope(:find)

        # Only join tables referenced in order or conditions since this is particularly slow on the pre-query.
        tables_from_conditions = conditions_tables(options)
        tables_from_order      = order_tables(options)
        all_tables             = tables_from_conditions + tables_from_order
        distinct_join_associations = all_tables.uniq.map{|table|
          join_dependency.joins_for_table_name(table)
        }.flatten.compact.uniq

        is_distinct = !options[:joins].blank? || include_eager_conditions?(options, tables_from_conditions) || include_eager_order?(options, tables_from_order)
        sql = "SELECT "
        if is_distinct
          sql << connection.distinct("#{connection.quote_table_name table_name}.#{primary_key}", options[:order])
        else
          sql << primary_key.to_s
        end
        sql << " FROM #{connection.quote_table_name table_name} "

        if is_distinct
          sql << distinct_join_associations.collect(&:association_join).join
          add_joins!(sql, options[:joins], scope)
        end

        add_conditions!(sql, options[:conditions], scope)
        add_group!(sql, options[:group], scope)

        if options[:order] && is_distinct
          connection.add_order_by_for_association_limiting!(sql, options)
        else
          add_order!(sql, options[:order], scope)
        end

        add_limit!(sql, options, scope)

        return sanitize_sql(sql)
      end

      def select_limited_ids_list(options, join_dependency)
        pk = columns_hash[primary_key]

        connection.select_all(
          construct_finder_sql_for_association_limiting(options, join_dependency),
          "#{name} Load IDs For Limited Eager Loading"
        ).collect { |row| connection.quote(row[primary_key.to_s], pk) }.join(", ")
      end

      def collection_accessor_methods(reflection, association_proxy_class, writer = true)
        collection_reader_method(reflection, association_proxy_class)

        if writer
          define_method("#{reflection.name}=") do |new_value|
            # Loads proxy class instance (defined in collection_reader_method) if not already loaded
            association = send(reflection.name)
            association.replace(new_value)
            association
          end

          define_method("#{reflection.name.to_s.singularize}_ids=") do |new_value|
            ids = (new_value || []).reject { |nid| nid.blank? }
            send("#{reflection.name}=", reflection.class_name.constantize.find(ids))
          end
          
          define_method("set_#{reflection.name}_target") do |target|
            #return if target.nil? and association_proxy_class == BelongsToAssociation
            association = association_proxy_class.new(self, reflection)
            association.target = target
            instance_variable_set("@#{reflection.name}", association)
          end

        end
      end

    end

    class HasAndBelongsToManyAssociation
      def insert_record(record, force=true)
        if record.new_record?
          if force
            record.save!
          else
            return false unless record.save
          end
        end

        if @reflection.options[:insert_sql]
          @owner.connection.insert(interpolate_sql(@reflection.options[:insert_sql], record))
        else
          columns = @owner.connection.columns(@reflection.options[:join_table], "#{@reflection.options[:join_table]} Columns")
          pkey = @reflection.primary_key_name.split(",")

          attributes = columns.inject({}) do |attrs, column|
            if pkey.is_a?(Array) and pkey.include?(column.name.to_s)
              attrs[column.name] = owner_quoted_id[pkey.index(column.name.to_s)]
            elsif column.name.to_s == @reflection.primary_key_name.to_s
              attrs[column.name] = owner_quoted_id
            elsif column.name.to_s == @reflection.association_foreign_key.to_s
              attrs[column.name] = record.quoted_id
            else
              if record.has_attribute?(column.name)
                value = @owner.send(:quote_value, record[column.name], column)
                attrs[column.name] = value unless value.nil?
              end
            end
            attrs
          end

          sql =
            "INSERT INTO #{@owner.connection.quote_table_name @reflection.options[:join_table]} (#{@owner.send(:quoted_column_names, attributes).join(', ')}) " +
            "VALUES (#{attributes.values.join(', ')})"

          @owner.connection.insert(sql)
        end

        return true
      end

      def delete_records(records)
        if sql = @reflection.options[:delete_sql]
          records.each { |record| @owner.connection.delete(interpolate_sql(sql, record)) }
        else
          ids = quoted_record_ids(records)
          table_name = @owner.connection.quote_table_name @reflection.options[:join_table]
          pks = @reflection.primary_key_name.split(",")
          if owner_quoted_id.is_a?(Array)
            pk_condition = [pks, owner_quoted_id].transpose.map{|k,v| "(#{k} = #{v})"}.join(" AND ")
          else
            pk_condition = "#{@reflection.primary_key_name} = #{owner_quoted_id}"
          end
          sql = "DELETE FROM #{table_name} WHERE #{pk_condition} AND #{@reflection.association_foreign_key} IN (#{ids})"
          @owner.connection.delete(sql)
        end
      end
    end
    
    class BelongsToAssociation
      def replace(record)
        counter_cache_name = @reflection.counter_cache_column

        if record.nil?
          if counter_cache_name && !@owner.new_record?
            @reflection.klass.decrement_counter(counter_cache_name, @owner[@reflection.primary_key_name]) if @owner[@reflection.primary_key_name]
          end
          @target = nil
          @reflection.primary_key_name.to_s.split(',').each_with_index {|col_name, index|
            @owner[col_name] = nil
          }
        else
          raise_on_type_mismatch(record)

          if counter_cache_name && !@owner.new_record?
            @reflection.klass.increment_counter(counter_cache_name, record.id)
            @reflection.klass.decrement_counter(counter_cache_name, @owner[@reflection.primary_key_name]) if @owner[@reflection.primary_key_name]
          end

          @target = (AssociationProxy === record ? record.target : record)
          #@owner[@reflection.primary_key_name] = record.id unless record.new_record?
          unless record.new_record?
            if record.respond_to?(:primary_keys)
              @reflection.primary_key_name.to_s.split(',').each_with_index {|col_name, index|
                @owner[col_name] = record.ids[index]
              }
            else
              @owner[@reflection.primary_key_name] = record.id
            end
          end
          @updated = true
          loaded
          record
        end

      end
    end
    
    class AssociationProxy
      def composite_join_clause(full_keys1, full_keys2)
        full_keys1 = [full_keys1.to_s] unless full_keys1.is_a?(Array)
        full_keys2 = [full_keys2.to_s] unless full_keys2.is_a?(Array)
      
        where_clause = [full_keys1, full_keys2].transpose.map do |key_pair|
          "#{key_pair.first}=#{key_pair.last}"
        end.join(" AND ")
      
        "(#{where_clause})"
      end

      def full_composite_join_clause(table1, full_keys1, table2, full_keys2)
        full_keys1 = [full_keys1.to_s] unless full_keys1.is_a?(Array)
        full_keys2 = [full_keys2.to_s] unless full_keys2.is_a?(Array)
        where_clause = [full_keys1, full_keys2].transpose.map do |key_pair|
          "#{table1}.#{key_pair.first}=#{table2}.#{key_pair.last}"
        end.join(" AND ")
      
        "(#{where_clause})"
      end
    end
  end
end
