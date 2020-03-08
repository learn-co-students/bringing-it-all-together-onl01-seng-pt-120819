# require_relative "../config/environment.rb"
class Dog 
     attr_accessor :id, :name, :breed
    #  attr_reader :id 
    # def initialize(name, breed, id=nil)
      def initialize(id: nil, name:, breed:)
       @id = id
       @name = name
       @breed = breed
     end

    def self.create_table
        sql = <<-SQL 
        CREATE TABLE IF NOT EXISTS dogs (
         id INTEGER PRIMARY KEY, 
         name TEXT, 
         breed TEXT
         ) 
         SQL
 
         DB[:conn].execute(sql) 
    
    end

    def self.drop_table
        sql = <<-SQL 
          DROP TABLE dogs
        SQL
        DB[:conn].execute(sql)  
    end
    
    def save
        sql = <<-SQL
        INSERT INTO dogs (name, breed) 
        VALUES (?, ?)
      SQL
    
      DB[:conn].execute(sql, self.name, self.breed)
    
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

      self
    end

    def self.create(attributes)
      dog = self.new(attributes)
      dog.save
  
      dog
    end

    def self.new_from_db(object_row)
        attributes = {
      :id => object_row[0],
      :name => object_row[1],
      :breed => object_row[2]
    }
    self.new(attributes)
    # binding.pry
    end
    
    def self.find_by_id(id)
        sql = <<-SQL
             SELECT * FROM dogs WHERE id = ?
             SQL
        #  binding.pry
         DB[:conn].execute(sql, id).map do |row|
            self.new_from_db(row)
          end.first
    end
    
    def self.find_or_create_by(name:, breed:)
       sql = <<-SQL
          SELECT * FROM dogs
            WHERE name = ? AND breed = ?
        SQL
    
    
         dog = DB[:conn].execute(sql, name, breed).first
    
      if dog
        new_dog = self.new_from_db(dog)
      else
         new_dog = self.create({:name => name, :breed => breed})
       end
        new_dog
    end

    def self.find_by_name(name)
            sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ?
            LIMIT 1
        SQL

        DB[:conn].execute(sql,name).map do |row|
            self.new_from_db(row)
        end.first

    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end
