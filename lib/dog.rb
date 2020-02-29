class Dog
    attr_accessor :name, :breed
    attr_reader :id
    def initialize(name:,breed:, id:nil)
        @name = name 
        @breed = breed
        @id = id 
    end

    def self.create_table 
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs(
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
        SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs")
    end

    def save 
        if self.id
            self 
        else 
        sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
        SQL

        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
        end
    end

    def self.create(stuff)
        doggo = Dog.new(stuff)
        doggo.save 
    end

    def self.new_from_db(stuff)
        pupper = create(name:stuff[1], breed:stuff[2], id:stuff[0])   
    end

    def self.find_by_id(id)

        sql = <<-SQL
        SELECT * FROM dogs
        WHERE id = ?
        SQL

        DB[:conn].execute(sql, id).collect do |row|
            self.new_from_db(row)
        end.first
    end

    def self.find_or_create_by(name:, breed:)
        doggo = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        if !doggo.empty?
            doggo_stuffo = doggo[0]
            id = doggo_stuffo[0]
            name =  doggo_stuffo[1]
            breed = doggo_stuffo[2]
        new_doggo = self.new(id:id, name:name, breed:breed)
        else
        new_doggo = self.create(name:name, breed:breed)
        end
        new_doggo
    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT * FROM dogs
        WHERE name = ?
        SQL
        DB[:conn].execute(sql,name).collect do |row|
            self.new_from_db(row)
        end.first
     end

     def update
        sql = <<-SQL
        UPDATE dogs 
        SET name = ?,
        breed = ? 
        WHERE id = ?
        SQL
        DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end