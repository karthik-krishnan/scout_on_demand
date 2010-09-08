if RUBY_PLATFORM =~ /java/
  require "db2jcc4.jar"
else
  warn "jdbc-db2 is only for use with JRuby"
end
