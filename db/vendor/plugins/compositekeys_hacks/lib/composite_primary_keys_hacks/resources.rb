module ActionController
    module Resources
        def action_options_for(action, resource, method = nil)
            default_options = { :action => action.to_s }
            require_id = !resource.kind_of?(SingletonResource)
            case default_options[:action]
            when "index", "new"; default_options.merge(add_conditions_for(resource.conditions, method || :get)).merge(resource.requirements)
            when "create";       default_options.merge(add_conditions_for(resource.conditions, method || :post)).merge(resource.requirements)
            when "show", "edit"; default_options.merge(add_conditions_for(resource.conditions, method || :get)).merge(resource.requirements(require_id))
            when "update";       default_options.merge(add_conditions_for(resource.conditions, method || :put)).merge(resource.requirements(require_id))
            when "destroy";      default_options.merge(add_conditions_for(resource.conditions, method || :delete)).merge(resource.requirements(require_id))
            else                  
                if require_id == false || resource.new_methods.values.flatten.include?(action) || 
                      resource.collection_methods.values.flatten.include?(action)
                    default_options.merge(add_conditions_for(resource.conditions, method)).merge(resource.requirements)
                else  
                    default_options.merge(add_conditions_for(resource.conditions, method)).merge(resource.requirements(require_id))
                end
            end
        end        
    end
end
