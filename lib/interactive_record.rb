require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def initialize(attributes={})
    attributes.each do |key, value|
      self.send("#{key}=", value)
    end

  end


  def self.column_names
      DB[:conn].results_as_hash = true
      sql = "PRAGMA table_info('#{table_name}')"
      table_info = DB[:conn].execute(sql)
      columns = []
      table_info.each do |column|
     columns << column["name"]
  end
  columns.compact
end

def self.table_name
  self.to_s.downcase.pluralize
end

def table_name_for_insert
  self.class.table_name

end

def col_names_for_insert
  self.class.column_names.delete_if {|col| col =="id" }.join(", ")

end

def values_for_insert
  values = []
  self.class.column_names.each do |col_name|
    values << "'#{send(col_name)}'" unless send(col_name).nil?
  end
  values.join(", ")

end





def save
  sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
  DB[:conn].execute(sql)
  @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
end

def self.find_by_name(name)
  
  DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE name = ?", name)

end

def self.find_by(attribute_hash)
  value = attribute_hash.values.first
  formatted_value = value.class == Fixnum ? value : "'#{value}'"
  sql = "SELECT * FROM #{self.table_name} WHERE #{attribute_hash.keys.first} = #{formatted_value}"
  DB[:conn].execute(sql)
end

 

    
  
end