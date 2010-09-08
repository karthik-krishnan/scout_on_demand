# (c) Copyright 2006 Nick Sieger <nicksieger@gmail.com>
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation files
# (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require 'autotest/rails_rspec'

class Autotest::HacksRailsRspec < Autotest::RailsRspec

  def initialize
    super
    @exceptions = %r%^(?:(\./(?:coverage|db|doc|log|public|script|nbproject|tmp|vendor\/rails|previous_failures.txt))|(.*/\.svn/.*))%    
    additional_test_mappings = {
      %r%^app/presenters/(.*)\.rb$% => proc { |_, m|
        ["spec/presenters/#{m[1]}_spec.rb"]
      },
      %r%^spec/presenters/.*rb$% => proc { |filename, _| 
	        filename
      },
    }        
    @test_mappings.merge!(additional_test_mappings)
  end
  
 alias_method :find_files_to_test_default, :find_files_to_test
  def find_files_to_test(files=find_files)
    updated = files.select { |filename, mtime|
      @files[filename] < mtime
    }

    p updated if $v unless updated.empty? or @last_mtime.to_i == 0

    # TODO: keep an mtime at app level and drop the files hash
    updated.each do |filename, mtime|
      @files[filename] = mtime
    end

    updated.each do |filename, mtime|
      tests_for_file(filename).each do |f|
        @files_to_test[f] # creates key with default value
      end
    end

    previous = @last_mtime
    @last_mtime = @files.values.max
    updated.size > 0 && @last_mtime > previous
  end

end
