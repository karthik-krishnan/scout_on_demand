cd ops
#cp config/mysql-database.example config/database.yml
export ORIGINAL_PATH=$PATH
export MY_RUBY_HOME=~/.ruby_versions/ruby-1.8.6-p383
export PATH=$GEM_HOME/bin:$MY_RUBY_HOME/bin:$ORIGINAL_PATH
script/server&
result_path=$PWD
cd /home/msuser1/workspace/cucumber_testing/
cucumber  --tags @scout --format html --out cucumber_report.html
cp cucumber_report.html "$result_path/doc/results.html"
