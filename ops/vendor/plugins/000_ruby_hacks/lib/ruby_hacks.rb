# RubyHacks

class Object
  def tap
    yield self
    self
  end
end

class String
  def t
    self
  end
end


class Object
  def duck_type?(*args)
    methods_to_respond_to = [*args].flatten
    methods_to_respond_to.all? { |sym| self.respond_to?(sym) }
  end
end

class Array
  def sort_on_multiple_attributes(a, b, fields)
    field, direction = fields.shift
    field = ('.' + field).scan(/\.(\w*)/).last[0] #This is to get the last word after any number of dots. like a.b.c should return c
    x, y = direction == 'DESC' ? [b, a] : [a, b]
    if x.send(field) != y.send(field) 
      x.send(field) <=> y.send(field)
    else
      fields.empty? ? 0 : sort_on_multiple_attributes(a, b, fields)
    end
  end
  
  def composite_sort(sql_style_order_by, bang = false)
    sort_fields_info = sql_style_order_by.split(',').collect{|a| a.split }
    sort_logic = Proc.new {|a,b| sort_on_multiple_attributes(a, b, sort_fields_info.dup) }
    if bang
      sort!(&sort_logic)
    else
      sort(&sort_logic)
    end
  end

  def composite_sort!(sql_style_order_by)
    composite_sort(sql_style_order_by, true)
  end
end

class Date
  #The following hack is to workaround a new behavior(bug?!?!!) in Ruby 1.8.6
  #I believe, some optimization is done in Ruby in Freeze method not to update certain data structures.
  def freeze
    cwday
    to_s
    super
  end
    
  alias :default_strftime :strftime
  def strftime(fmt='%F')
    #return dup.strftime(fmt) if frozen?
    o = ''
    fmt.scan(/%[EO]?.|./mo) do |c|
      cc = c.sub(/\A%[EO]?(.)\z/mo, '%\\1')
      case cc
      when '%o'
        o << cardinalize(mday)
      else
        o << default_strftime(cc)
      end
    end
    o
  end
    
  private
  def cardinalize(value)
    if value > 10 && value < 20
      suffix = 'th'
    else
      suffix = %w{th st nd rd th th th th th th}[value % 10]
    end
    value.to_s + suffix
  end

end

class Array
  def contains?(sub_array)
    self.delete_distinct(sub_array).size == (self.size - sub_array.size)
  end
  
  def delete_distinct(sub_array, bang = false)
    array_clone = bang ? self : self.dup
    sub_array.each {|s| found_at = array_clone.index(s); array_clone.delete_at(found_at) if found_at }
    array_clone
  end
  
  def delete_distinct!(sub_array)
    delete_distinct(sub_array, true)
  end
end

class Object
  def inspect_contents
    puts "START OF DUMP"
    a = self.inspect
    classes = []
    pos = 0
    while pos <= a.size
      pos = (a =~ /(#<[^0]+)/)
      classes << $1 unless classes.include? $1
      a = a[pos+$1.size..a.size]
    end
    require 'pp'
    pp classes.sort
    puts "END OF DUMP"
  end
end
