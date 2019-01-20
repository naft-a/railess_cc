require "sqlite3"

module Db
  class Database
    def self.create_new
      db = SQLite3::Database.new "test.db"
      db.execute("PRAGMA foreign_keys = ON")

      db.execute <<-SQL
        create table products (
          product_id integer PRIMARY KEY,
          external_id varchar(30),
          branded_name text NOT NULL,
          unbranded_name text NOT NULL,
          currency varchar(50),
          price varchar(50),
          price_label varchar(50),
          click_url text NOT NULL,
          description text NOT NULL,
          image text,
          discount varchar(30)
        );
      SQL

      db.execute <<-SQL
        create table colors (
          color_id integer PRIMARY KEY,
          name VARCHAR(50),
          image text
        );
      SQL

      db.execute <<-SQL
        create table categories (
          category_id integer PRIMARY KEY,
          identifier text,
          name text,
          full_name text,
          short_name text
        );
      SQL

      db.execute <<-SQL
        create table sizes (
          size_id integer PRIMARY KEY,
          external_id integer,
          name VARCHAR(30),
          canonical_size VARCHAR(50)
        );
      SQL

      db.execute <<-SQL
        create table product_colors (
          product_id integer,
          color_id integer,
          PRIMARY KEY (product_id, color_id),
          FOREIGN KEY (product_id) REFERENCES products (product_id)
          ON DELETE CASCADE ON UPDATE NO ACTION,
          FOREIGN KEY (color_id) REFERENCES colors (color_id)
          ON DELETE CASCADE ON UPDATE NO ACTION
        );
      SQL

      db.execute <<-SQL
        create table product_categories (
          product_id integer,
          category_id integer,
          PRIMARY KEY (product_id, category_id),
          FOREIGN KEY (product_id) REFERENCES products (product_id)
          ON DELETE CASCADE ON UPDATE NO ACTION,
          FOREIGN KEY (category_id) REFERENCES categories (category_id)
          ON DELETE CASCADE ON UPDATE NO ACTION
        );
      SQL

      db.execute <<-SQL
        create table product_sizes (
          product_id integer,
          size_id integer,
          PRIMARY KEY (product_id, size_id),
          FOREIGN KEY (product_id) REFERENCES products (product_id)
          ON DELETE CASCADE ON UPDATE NO ACTION,
          FOREIGN KEY (size_id) REFERENCES sizes (size_id)
          ON DELETE CASCADE ON UPDATE NO ACTION
        );
      SQL
    end

    def self.recreate
      self.with_open_db do |db|
        db.execute("PRAGMA foreign_keys = OFF")
        db.execute("DROP TABLE products;")
        db.execute("DROP TABLE colors;")
        db.execute("DROP TABLE categories;")
        db.execute("DROP TABLE sizes;")
        db.execute("DROP TABLE product_colors;")
        db.execute("DROP TABLE product_categories;")
        db.execute("DROP TABLE product_sizes;")
      end
      self.create_new
    end

    def self.insert_product(product)
      self.with_open_db do |db|
        db.execute(
          "INSERT INTO products (
            external_id, branded_name, unbranded_name, currency,
            price, price_label, click_url, description, image, discount
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);",
          [
            product.external_id,
            product.branded_name,
            product.unbranded_name,
            product.currency,
            product.price,
            product.price_label,
            product.click_url,
            product.description,
            product.image,
            product.discount
          ]
        )
        db.last_insert_row_id
      end
    end

    def self.insert_color(color)
      self.with_open_db do |db|
        db.execute(
          "INSERT INTO colors ( name, image )
          VALUES (?, ?, ?);",
          [
            color.name,
            color.image
          ]
        )
        db.last_insert_row_id
      end
    end

    def self.insert_category(category)
      self.with_open_db do |db|
        db.execute(
          "INSERT INTO category ( identifier, name, full_name, short_name )
          VALUES (?, ?, ?);",
          [
            category.identifier,
            category.name,
            category.full_name,
            category.short_name
          ]
        )
        db.last_insert_row_id
      end
    end

    def self.insert_size(size)
      self.with_open_db do |db|
        db.execute(
          "INSERT INTO sizes ( external_id, name, canonical_size )
          VALUES (?, ?, ?);",
          [
            size.external_id,
            size.name,
            size.canonical_size
          ]
        )
        db.last_insert_row_id
      end
    end

    def self.insert_product_color()
      self.with_open_db do |db|
        db.execute(
          "INSERT INTO product_colors ( product_id, color_id ) VALUES 
          ((), ) "
        )
        db.last_insert_row_id
      end
    end

    def self.with_open_db
      db = SQLite3::Database.open('test.db')
      yield(db)
    end

    def self.start_with_new
      self.recreate
      yield
    end
  end
end