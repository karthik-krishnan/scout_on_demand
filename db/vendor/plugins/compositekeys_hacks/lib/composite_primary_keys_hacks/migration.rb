ActiveRecord::ConnectionAdapters::TableDefinition.class_eval <<-'EOF'
  def pk(*column_names)
        column = ActiveRecord::ConnectionAdapters::ColumnDefinition.new(@base, column_names, :pk)
        @columns << column
        @columns.delete self['id']
        self
  end
EOF