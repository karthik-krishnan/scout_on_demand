# FormatColumnHacks

module Formatters
  class FormatAmount < Format
    include ActionView::Helpers::NumberHelper
    
    PREFIX_SYMBOL = 'PREFIX_SYMBOL'
    SUFFIX_SYMBOL = 'SUFFIX_SYMBOL'
    PREFIX_CODE = 'PREFIX_CODE'
    SUFFIX_CODE = 'SUFFIX_CODE'
    NO_SYMBOL = 'NONE'    
    
    NEGATIVE_SIGN = 'N'
    NEGATIVE_SIGN_WITH_RED_COLOR = 'NR'
    PARENTHESIS = 'P'
    PARENTHESIS_WITH_RED_COLOR = 'PR'
  
    class_inheritable_accessor :currency_symbol, :negative_amount_style
    
    Formatters::FormatAmount.currency_symbol = NO_SYMBOL
    Formatters::FormatAmount.negative_amount_style = NEGATIVE_SIGN
    
    def from(value, options = {})
      ccy_code = "#{value.currency.code}"
      ccy_symbol = "#{value.currency.symbol}"
      parenthesis = false
      if value.to_f < 0 && parenthesis_for_negative_amount?
        value = -value
        parenthesis = true
      end
      precision = precision(value.currency.scale)
      delimiter = value.currency.formatter.thousands_separator
      formatted_amount = number_to_currency(value, :delimiter => delimiter, :unit => '', :precision => precision)
      ccy_symbol_format = options[:ccy_symbol_format] || Formatters::FormatAmount.currency_symbol
      a = format_with_ccy ccy_symbol_format, ccy_code, ccy_symbol, formatted_amount, parenthesis
      a
    end
    
    def parenthesis_for_negative_amount?
      (Formatters::FormatAmount.negative_amount_style == PARENTHESIS || 
          Formatters::FormatAmount.negative_amount_style == PARENTHESIS_WITH_RED_COLOR) ? true : false
    end
    
    def format_with_ccy(ccy_symbol_format, ccy_code, ccy_symbol, formatted_amount, parenthesis)
      result = ''
      case ccy_symbol_format
      when PREFIX_SYMBOL
        result = ccy_symbol + ' ' + formatted_amount
      when SUFFIX_SYMBOL
        result = formatted_amount + ' ' + ccy_symbol
      when PREFIX_CODE
        result = ccy_code + ' ' + formatted_amount
      when SUFFIX_CODE
        result = formatted_amount + ' ' + ccy_code
      else
        result = formatted_amount
      end
      parenthesis ? "(#{result})" : result
    end
      
    def precision(scale) 
      s = scale
      p = 0
      while s != 1
        s = s/10
        p += 1
      end
      p
    end
    
    def to(str, options = {})
      str
    end
    
  end

  class FormatDate < Format
    
    class_inheritable_accessor :date_formatter_string
    
    Formatters::FormatDate.date_formatter_string = '%Y-%m-%d'

    def from(value, options = {})
      value.strftime(Formatters::FormatDate.date_formatter_string)
    end
      
    def to(str, options = {})
      Date.strptime(str, Formatters::FormatDate.date_formatter_string) rescue nil
    end
  end
  
  class FormatDateTime < Format
    
    class_inheritable_accessor :date_time_formatter_string
    
    Formatters::FormatDateTime.date_time_formatter_string = '%Y-%m-%d %I:%M:%S %p'

    def from(value, options = {})
      value.strftime(Formatters::FormatDateTime.date_time_formatter_string)
    end
      
    def to(str, options = {})
      str
    end
  end  
  
  class FormatAccountMask < Format
    
    def from(value, options = {})
      unless value.duck_type?(:account_num, :account_mask, :account_mask_char)
        raise "value should respond to :account_num, :account_mask, :account_mask_char"
      end
      raise "Mask is empty" if value.account_mask.empty?
      raise "Mask should make at least one char visible" if value.account_mask.count('#') == 0
      raise "Length mismatch" if value.account_mask.length - value.account_mask.count('-') != value.account_num.length
      raise "Mask contains character other than #, - and X" unless value.account_mask.gsub(/(#|X|-)/,'').empty?
      account_mask_char = (value.account_mask_char.nil? || value.account_mask_char.empty?) ? 'x' : value.account_mask_char
      raise "Mask char should be either empty or single char" if account_mask_char.length > 1
      
      do_masking value.account_num, account_mask_char, value.account_mask

    end
    
    def do_masking(account_num, account_mask_char, pattern)
      result = pattern.dup
      if account_num.size <= pattern.size
        i = 0
        j = 0
        finished_stuff = false
        pattern.each_char{|char|
          unless finished_stuff
            case char
            when 'X'
              result[i] = account_mask_char
            when '-'
              result[i] = '-'
              j -= 1
            when '#'
              result[i] = account_num[j]
            end
            i += 1
            j += 1
            #Strangely in JRuby this doesn't work.
            #break if j == account_num.size   
            finished_stuff = true if j == account_num.size
          end
        }
        result
      else
        account_num
      end
    end
    
    def to(str, options ={})
      
    end
  end
end
