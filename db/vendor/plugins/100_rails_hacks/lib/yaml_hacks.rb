
## Hack Reason ##
#
# For the purposes of I18N, we have enhanced Date's to_s to emit
# based on the choosen I18N date format.
# However, for YAML serialization purposes, only the ISO format would work
# Hence overriding YAML, serialation to use the to_s with :db formatting
# option which will emit date string in ISO format

#This is placed in Rails hacks as opposed to Ruby hacks because, to_s method
#is only enhanced by Rails to add :db formatting option


class Date
	def to_yaml( opts = {} )
		YAML::quick_emit( object_id, opts ) do |out|
            out.scalar( "tag:yaml.org,2002:timestamp", self.to_s(:db), :plain )
        end
	end
end