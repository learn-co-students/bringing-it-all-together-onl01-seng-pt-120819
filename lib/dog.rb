require "pry"

class Dog
    attr_accessor :name, :breed, :id
    attr_reader 
    
    def initialize(attributes)
      attributes.each do |key, value|
        self.send("#{key}=", value)
        self.id ||= nil
      end

    #   @name = attributes[:name]
    #   @breed = attributes[:breed]
    #   @id = attributes[:id]
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE dogs (
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
        if self.id
            self.update
        else
        sql = <<-SQL
            INSERT INTO dogs (name, breed) VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end

    def update
        sql = <<-SQL
        UPDATE dogs SET name = ?, breed = ? WHERE id = ?
        SQL

        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ?
        SQL
        DB[:conn].execute(sql, name).map { |row| self.new_from_db(row) }.first
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE id = ?
        SQL
        DB[:conn].execute(sql, id).map { |row| self.new_from_db(row) }.first
    end


    def self.new_from_db(row)
        id = row[0]
        name = row[1]
        breed = row[2]
        new_dog = self.new(name:name, breed:breed, id:id)
        new_dog
    end

    def self.create(hash)
        #do the hash thing as the previous lab
        # hash = {}
        id = hash[:id]
        name = hash[:name]
        breed = hash[:breed]
        dog = Dog.new(hash)
        dog.save
        dog
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ? AND breed = ?
        SQL

        dog = DB[:conn].execute(sql, name, breed).first  

        if dog 
            new_dog = self.new_from_db(dog)
        else
            new_dog = self.create({:name => name, :breed => breed })
        end
        new_dog
    end




  end