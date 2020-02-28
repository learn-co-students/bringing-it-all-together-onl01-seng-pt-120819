class Dog
 attr_accessor :name, :breed
 attr_reader :id

  def initialize(name:, breed:, id:nil)
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
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  def self.new_from_db(array)
     id = array[0]
     name = array[1]
     breed = array[2]
     dog = self.new(name:name, breed:breed,id:id)
     dog
  end

  def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create(hash_attributes)
    dog = Dog.new(hash_attributes)
    dog.save
    dog  
  end

  def save
    if self.id
        self    
    else
    sql = <<-SQL
    INSERT INTO dogs (name, breed)
    VALUES (?,?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
    end
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

  def self.find_or_create_by(name:,breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed).first
    if !dog.empty?
        dog_data = dog[0]
    new_dog = Dog.new(dog_data[0], dog_data[1], dog_data[2])
    else
    new_dog = self.create(name:name, breed:breed)
    end
   new_dog
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


end
