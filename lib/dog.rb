class Dog
  attr_accessor :name, :breed
  attr_reader :id
  
  def initialize(id:nil, name:, breed:) 
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
    sql = "DROP TABLE IF EXISTS dogs"
    
    DB[:conn].execute(sql)
  end
  
  def save
    if self.id == nil
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL
    
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0] 
    else
      self.update
    end
    self
  end
  
  def update #updates in DB
    sql = <<-SQL 
      UPDATE dogs 
      SET name = ?
      WHERE id = ?
    SQL
    
    DB[:conn].execute(sql, self.name, self.id)
  end

  def self.new_from_db(array)
    self.new(id:array[0], name:array[1], breed:array[2])
  end
  
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
    SQL
  
    result = DB[:conn].execute(sql, name)
    self.new_from_db(result[0])
  end
  
  def self.create(attributes_hash)
    dog = Dog.new(attributes_hash)
    dog.save
    dog
  end
  
  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL
  
    result = DB[:conn].execute(sql, id)
    self.new_from_db(result[0])
  end
  
  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      AND breed = ?
      LIMIT 1
    SQL
    
    result = DB[:conn].execute(sql, name, breed)
    
    if !result.empty?
      db_return = result[0]
      dog = Dog.new(id: db_return[0], name: db_return[1], breed: db_return[2])
    else 
      dog = Dog.create(name: name, breed: breed)
    end
      dog
  end

end


