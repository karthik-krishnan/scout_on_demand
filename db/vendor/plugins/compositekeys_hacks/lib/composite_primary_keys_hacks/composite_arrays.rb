module CompositePrimaryKeys
    class CompositeArray < Array
        def to_s
            collect {|x|
                case x
                when Time
                    x.to_s(:db)
                else
                    x
                end
            }.join(ID_SEP)
        end
    end
end