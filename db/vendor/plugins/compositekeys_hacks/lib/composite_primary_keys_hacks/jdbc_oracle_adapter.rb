if RUBY_PLATFORM =~ /java/ 
	module JdbcSpec
		module Oracle
			  def supports_count_distinct? #:nodoc:
			    false
			  end
		end
	end
end
