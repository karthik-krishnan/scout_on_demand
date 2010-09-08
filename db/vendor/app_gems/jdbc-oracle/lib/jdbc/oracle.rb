if RUBY_PLATFORM =~ /java/
  require "ojdbc14.jar"
else
  warn "jdbc-oracle is only for use with JRuby"
end
