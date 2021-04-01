class Dog
    attr_accessor :name, :breed, :id

    def initialize(id:nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed 
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs(
                id INTEGER PRIMARY KEY,
                name TEST,
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

    def self.create(row)
        dog = self.new(name:row[:name], breed:row[:breed])
        dog.save
        dog
    end

    def self.new_from_db(row)
        dog = self.new(id: row[0], name:row[1], breed:row[2])
        dog 
    end

    def self.find_by_id(id)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE id = ?
        SQL
        result = DB[:conn].execute(sql, [id]).flatten
        self.new(id:result[0], name:result[1], breed:result[2])
    end

   def self.find_or_create_by(row)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", row[:name], row[:breed])
            if !dog.empty?
                dog_data = dog[0]
              
                
                dog = self.new(id:self.find_by_name(dog_data[1]).id, name:dog_data[1], breed:dog_data[2])
                # binding.pry
            else 
                dog = self.create(name:row[:name], breed:row[:breed])
                # self.find_by_name
            end
        dog
    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE name = ?
        SQL
        result = DB[:conn].execute(sql, [name]).flatten
        self.new(id:result[0], name:result[1], breed:result[2])
    end

    def update
        sql = <<-SQL
        UPDATE dogs 
        SET name = ?, breed = ?
        WHERE id = ?
        SQL
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end