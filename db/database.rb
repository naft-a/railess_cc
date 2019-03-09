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
          color_id varchar(30),
          brand text,
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
          name VARCHAR(50)
        );
      SQL

      db.execute <<-SQL
        create table categories (
          category_id integer PRIMARY KEY,
          identifier text,
          sex text,
          name text,
          full_name text,
          short_name text
        );
      SQL

      db.execute <<-SQL
        create table sizes (
          size_id integer PRIMARY KEY,
          external_id integer,
          name VARCHAR(30)
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

    def self.drop_all
      self.with_open_db do |db|
        db.execute("PRAGMA foreign_keys = OFF")
        db.execute("DROP TABLE products;")
        db.execute("DROP TABLE colors;")
        db.execute("DROP TABLE categories;")
        db.execute("DROP TABLE sizes;")
        db.execute("DROP TABLE product_categories;")
        db.execute("DROP TABLE product_sizes;")
      end
    end

    def self.recreate
      self.drop_all
      self.create_new
    end

    def self.insert_product(product, color_id)
      self.with_open_db do |db|
        db.execute(
          "INSERT INTO products (
            external_id, color_id, brand, branded_name, unbranded_name, currency,
            price, price_label, click_url, description, image, discount
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);",
          [
            product.external_id,
            color_id,
            product.brand.name,
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
          "INSERT INTO colors ( name )
          VALUES (?);",
          [
            color.name
          ]
        )
        db.last_insert_row_id
      end
    end

    def self.insert_category(category, sex)
      self.with_open_db do |db|
        db.execute(
          "INSERT INTO categories ( identifier, name, sex, full_name, short_name )
          VALUES (?, ?, ?, ?, ?);",
          [
            category.identifier,
            category.name,
            sex,
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
          "INSERT INTO sizes ( external_id, name )
          VALUES (?, ?);",
          [
            size.external_id,
            size.name
          ]
        )
        db.last_insert_row_id
      end
    end

    def self.insert_product_category(product_id, category_id)
      self.with_open_db do |db|
        db.execute(
          "INSERT INTO product_categories ( product_id, category_id ) VALUES
          (?, ?);",
          [
            product_id,
            category_id
          ]
        )
        db.last_insert_row_id
      end
    end

    def self.insert_product_size(product_id, size_id)
      self.with_open_db do |db|
        db.execute(
          "INSERT INTO product_sizes ( product_id, size_id ) VALUES
          (?, ?);",
          [
            product_id,
            size_id
          ]
        )
        db.last_insert_row_id
      end
    end

    def self.get_category_id_by_identifier(identifier)
      self.with_open_db do |db|
        db.get_first_value(
          "SELECT category_id FROM categories WHERE identifier = ?",
          identifier
        )
      end
    end

    def self.get_color_id_by_name(name)
      self.with_open_db do |db|
        db.get_first_value(
          "SELECT color_id FROM colors WHERE name = ?",
          name
        )
      end
    end

    def self.get_size_id_by_name(name)
      self.with_open_db do |db|
        db.get_first_value(
          "SELECT size_id FROM sizes WHERE name = ?",
          name
        )
      end
    end

    def self.with_open_db
      db = SQLite3::Database.open('test.db')
      if block_given?
        yield(db)
      else
        db
      end
    end

    def self.open?
      !self.with_open_db.closed?
    end

    def self.start_with_new
      self.recreate
      yield
    end
  end
end