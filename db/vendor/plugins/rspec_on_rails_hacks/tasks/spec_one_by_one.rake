namespace :lfs do
  namespace :spec do 
    desc "List spec/examples"
    task :list do
      spec_file_or_dir = ENV["FILE"] || 'spec'
      i = 1
      build_names_list(spec_file_or_dir, :example).each {|name|
        puts "#{i}. #{name}"
        i = i+1
      }
    end
    
    desc "Not Implemented spec/examples"
    task :list_not_implemented_examples do
      spec_file_or_dir = ENV["FILE"] || 'spec'
      i = 1
      build_names_list(spec_file_or_dir, :not_implemented_example).each {|name|
        puts "#{i}. #{name}"
        i = i+1
      }
    end
    
    desc "Run spec files one by one"
    task :one_by_one => "db:test:prepare" do
      output_file = 'spec_errors.txt'
      File.delete(output_file) if File.exist?(output_file)
      spec_file_or_dir = ENV["FILE"] || 'spec'
      index = ENV["INDEX"]
      type = index ? :example : :behaviour
      spec_list = build_names_list(spec_file_or_dir, type) 
      spec_list = ENV["INDEX"] ? [spec_list[ENV["INDEX"].to_i - 1]] : spec_list
      spec_list.each {|spec_info|
        if spec_info.include?("?::?")
          spec_parts = spec_info.split("?::?")
          spec_name = spec_parts[1]
          spec_path = spec_parts[0]
          puts "Running spec - #{spec_name}" 
          spec_cmd = "script/spec #{spec_path} -e \"#{spec_name}\" -f specdoc -c 2>&1"
          out = `#{spec_cmd}` 
          result_line = out.split("\n").last
          puts result_line
          if result_line =~/(\d+)\sexample/
            failures = result_line.scan(/(\d+)\sfailure/)
            errors = result_line.scan(/(\d+)\serror/)
            if (!failures.empty? && failures[0][0].to_i > 0) || (!errors.empty? && errors[0][0].to_i > 0)
              File.open(output_file, 'a') {|of| of.puts out }
              puts out
            end
          end
        end
      }
      raise "one-by-one specs failed" if File.exists?(output_file)
    end
  end
end


def build_names_list(spec_file_or_dir, mode = :behaviour)
  puts "Generating names list..."
  names_list_file = 'spec_names_list.txt'
  File.delete(names_list_file) if File.exist?(names_list_file)
  File.open(names_list_file, 'w') { }
  case mode
  when :behaviour
    formatter = 'ListBehaviourNamesFormatter'
  when :example
    formatter = 'ListExampleNamesFormatter'
  when :not_implemented_example
    formatter = 'ListNotImplementedExampleNamesFormatter'
  end
  formatter_path = File.expand_path(File.join(File.dirname(__FILE__), '..','lib'))
  `script/spec #{spec_file_or_dir} -r #{formatter_path}/rspec_formatters.rb -f #{formatter} > #{names_list_file}`
  names_list = IO.readlines(names_list_file)
  #File.delete(names_list_file)
  raise "Unable to get names list" if names_list.size == 0
  names_list.collect! {|spec_name| spec_name.chomp!}.uniq
end
