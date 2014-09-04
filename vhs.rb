module Vhs

  def self.create_classes
    db = get_table_names.map do |i|
      unless i[-3..-1] == 'ies'
        i.capitalize[0..-2]
      else
        i.capitalize[0..-4] + 'y'
      end
    end
    db.each do |table_name|
      const_set(table_name, Class.new(Template))
    end
  end

  class Template
    attr_reader :id

    def initialize(attributes)
      attributes.each_pair { |key, value| instance_variable_set(('@' + key), value) }
      attributes.each_key { |key| define_singleton_method(key.to_sym) { instance_eval(('@' + key)) } }
      unless self.class.to_s[-1] == 'y'
        @table = self.class.to_s.gsub(/Vhs::/, '').downcase.concat("s")
      else
        @table = self.class.to_s.gsub(/Vhs::/, '').downcase[0..-2].concat("ies")
      end
      @attributes = attributes
    end

    def create
      keys = @attributes.keys.join(', ')
      values = @attributes.values.map do|value|
        "'" + value.to_s + "'"
      end
      values = values.join(', ')
      results = DB.exec("INSERT INTO #{@table} (#{keys}) VALUES (#{values}) RETURNING id;")
      @id = results.first['id'].to_i
    end

    def self.read(attributes)
      items = []
      columns = columnize(attributes)
      selectors = selectorize(attributes)
      current_table = self.retrieve_table
      results = DB.exec("SELECT * FROM #{current_table} WHERE (#{columns}) = (#{selectors});")
      results.each { |result| items << self.new(result) }
      items
    end

    def self.update(attributes, selector)
      current_table = self.retrieve_table
      columns = columnize(attributes)
      new_values = selectorize(attributes)
      DB.exec("UPDATE #{current_table}
      SET (#{columns}) = (#{new_values})
      WHERE #{selector.keys[0]}= '#{selector.values[0]}';")
    end

    def self.delete(attributes)
      current_table = self.retrieve_table
      columns = columnize(attributes)
      selectors = selectorize(attributes)
      DB.exec("DELETE FROM #{current_table} WHERE #{columns}= #{selectors};")
    end

    def self.list
      self.read("'*'" => '*')
    end

    def self.join_by_name(attributes, selector = 'name')
      items = []
      left_table = self.retrieve_table
      right_table = attributes['right_table']
      join_table = attributes['join_table']
      left_join_id = left_table[0..-2].concat('_id')
      right_join_id = right_table[0..-2].concat('_id')
      name = attributes['name']
      results = DB.exec("SELECT #{left_table}.* FROM #{right_table}
              JOIN #{join_table} on (#{right_table}.id = #{join_table}.#{right_join_id})
              JOIN #{left_table} on (#{join_table}.#{left_join_id} = #{left_table}.id)
              WHERE #{right_table}.#{selector} = '#{name}'")
      results.each { |result| items << self.new(result) }
      items
    end

    def self.columnize(attributes)
      attributes.keys.join(', ')
    end

    def self.selectorize(attributes)
      attributes.values.map { |selector| "'" + selector.to_s + "'" }.join(', ')
    end

    def self.retrieve_table
      unless self.inspect.to_s[-1] == 'y'
        @table = self.inspect.to_s.gsub(/Vhs::/, '').downcase.concat("s")
      else
        @table = self.inspect.to_s.gsub(/Vhs::/, '').downcase[0..-2].concat("ies")
      end
    end

  end

  def self.get_table_names
    db_return = DB.exec("SELECT table_name
                         FROM information_schema.tables
                         WHERE table_schema='public'
                         AND table_type='BASE TABLE';")
    db_array = db_return.map { |i| i.values }.flatten
  end
end
