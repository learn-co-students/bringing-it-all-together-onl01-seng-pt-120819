class Dog

    attr_accessor :name, :breed, :id #has a name and a breed

    def initialize(id: nil, name:, breed:) #has an id that defaults to `nil` on initialization and accepts key value pairs as arguments to initialize
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table #creates the dogs table in the database
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY,
                name TEXT, 
                breed TEXT
            )
        SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table #drops the dogs table from the database
        sql = "DROP TABLE dogs"

        DB[:conn].execute(sql)
    end
    
    def save #saves an instance of the dog class to the database
        sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
        SQL

        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0] #sets the given dogs `id` attribute
        
        self #returns an instance of the dog class
    end

    def self.create(name:, breed:) #takes in a hash of attributes and uses metaprogramming to create a new dog object
        dog = Dog.new(name: name, breed: breed)
        dog.save #then it uses the #save method to save that dog to the database
        dog #returns a new dog object
    end

    def self.new_from_db(row) #creates an instance with corresponding attribute values
        id = row[0]
        name = row[1]
        breed = row[2]
        self.new(id: id, name: name, breed: breed)
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE id = ?
            LIMIT 1
        SQL

        DB[:conn].execute(sql, id).map do |row| #returns a new dog object by id
            self.new_from_db(row)
        end.first
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
            SELECT *
            FROM dogs 
            WHERE name = ?
            AND breed = ?
            LIMIT 1
        SQL

        dog = DB[:conn].execute(sql, name, breed)

        if !dog.empty? #creates an instance of a dog if it does not already exist
            dog_data = dog[0]
            dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
        else #when two dogs have the same name and different breed, it returns the correct dog
            dog = self.create(name: name, breed: breed)
        end
        dog #when creating a new dog with the same name as persisted dogs, it returns the correct dog
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * 
            FROM dogs
            WHERE name = ?
            LIMIT 1
        SQL

        DB[:conn].execute(sql, name).map do |row| #returns an instance of dog that matches the name from the DB
            self.new_from_db(row)
        end.first
    end

    def update #updates the record associated with a given instance
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"

        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end