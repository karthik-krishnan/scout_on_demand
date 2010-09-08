cd ops
#cp config/mysql-database.example config/database.yml
export ORIGINAL_PATH=$PATH
export MY_RUBY_HOME=~/.ruby_versions/ruby-1.8.6-p383
export PATH=$GEM_HOME/bin:$MY_RUBY_HOME/bin:$ORIGINAL_PATH
script/server&
cd ../cucumber_testing
cucumber  --tags @scout
