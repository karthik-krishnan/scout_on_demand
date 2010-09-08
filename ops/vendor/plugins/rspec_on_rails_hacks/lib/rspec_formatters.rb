require 'spec/runner/formatter/base_text_formatter'

class ListBehaviourNamesFormatter < Spec::Runner::Formatter::BaseTextFormatter   
  
  def add_example_group(example_group)
    @behaviour_name = example_group.description.gsub(/\(Spec::Rails.*\)/,'')
    @example_group = example_group
    @output.puts "#{example_group.spec_path.gsub(/\:.*/ ,'')}?::?#{@behaviour_name}"
    @output.flush
  end

  def example_started(name)
  end

  def example_failed(name, counter, failure)
  end

  def dump_failure(counter, failure)
  end

  def dump_summary(duration, example_count, failure_count, not_implemented_count)
  end
end

class ListExampleNamesFormatter < Spec::Runner::Formatter::BaseTextFormatter      

  def add_example_group(example_group)
    @behaviour_name = example_group.description.gsub(/\(Spec::Rails.*\)/,'')
    @example_group = example_group
  end
  
  def example_started(name)
    @output.puts "#{@example_group.spec_path.gsub(/\:.*/ ,'')}?::?#{@behaviour_name} #{name.to_s.gsub(/\(Spec::Rails.*\)/,'')}"
    @output.flush
  end

  def example_failed(name, counter, failure)
  end

  def dump_failure(counter, failure)
  end

  def dump_summary(duration, example_count, failure_count, not_implemented_count)
  end
end


class ListNotImplementedExampleNamesFormatter < Spec::Runner::Formatter::BaseTextFormatter      

  def add_example_group(example_group)
    @behaviour_name = example_group.description.gsub(/\(Spec::Rails.*\)/,'')
    @example_group = example_group
  end
  
  def example_started(name)
  end

  def example_failed(name, counter, failure)
  end

  def dump_failure(counter, failure)
  end

  def dump_summary(duration, example_count, failure_count, not_implemented_count)
  end
  
  def example_not_implemented(name)
    @output.puts "#{@behaviour_name} - #{name}"
    @output.flush
  end
end