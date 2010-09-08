class Rake::Application
  
  def tasks_hash
    @tasks
  end
  
  def replace_last_task_action(task, block)
    actions = task.instance_variable_get(:@actions)
    actions.delete(actions.last)
    actions << block
  end
  
end

class Rake::Task
  
  def name= (new_name)
    @name = new_name
  end
  
  def clone_some_inside_vars
    @lock = Mutex.new
    @already_invoked = false
    @actions = @actions.dup
    @comment = @comment.dup
  end
  
  def replace_comment=(comment)
    @comment = comment
  end
  
end


# Rake allows the same task name to be specified multiple times, where 
# each successive task definition appends to a list of actions to 
# perform. Therefore, an application specific task cannot redefine a 
# previously defined task. These methods here allow tasks to be 
# redefined and renamed. 

module Rake 
  class Task 

    # Clear all existing actions for the given task and then set the 
    # action for the task to the given block. 
    def self.redefine_task(args, &block)
      comment = args[:desc]
      task_name = args[:task_name]
      task_instance = tasks.find {|t| t.name == task_name }
      raise "Original task not found" unless task_instance
      task_instance.replace_comment = comment 
      Rake.application.replace_last_task_action(task_instance, block) 
    end 

    def remove_prerequisite(task_name) 
      name = task_name.to_s 
      @prerequisites.delete(name) 
    end

    def add_prerequisite(task_name)
      name = task_name.to_s
      @prerequisites.add(name)
    end
  end 
end 

# Clear all existing actions for the given task and then set the 
# action for the task to the given block. 
def redefine_task(args, &block) 
  Rake::Task.redefine_task(args, &block) 
end 

# Alias one task name to another task name. This let's a following 
# task rename the original task and still depend upon it. 
def alias_task(new_name, old_name) 
  original_task = Rake.application.tasks_hash[old_name.to_s]
  copied_task =  original_task.dup
  Rake.application.tasks_hash[new_name.to_s] = copied_task
  Rake.application.tasks_hash[old_name.to_s] = original_task
  copied_task.name = new_name
  copied_task.clone_some_inside_vars
end

