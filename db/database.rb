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
          image text NOT NULL,
          discount varchar(30)
        );
      SQL

      db.execute <<-SQL
        create table colors (
          color_id integer PRIMARY KEY,
          name VARCHAR(50),
          image text NOT NULL
        );
      SQL

      db.execute <<-SQL
        create table categories (
          category_id integer PRIMARY KEY,
          identifier text NOT NULL,
          name text NOT NULL,
          full_name text NOT NULL,
          short_name text NOT NULL
        );
      SQL

      db.execute <<-SQL
        create table sizes (
          size_id integer PRIMARY KEY,
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
    end

    def test_db
      SQLite3::Database.open('test.db')
    end
  end
end