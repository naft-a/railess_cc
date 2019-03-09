#!/usr/bin/ruby
require 'pry'
require 'yaml'
require 'httparty'

require_relative 'objects/product.rb'
require_relative 'core/worker.rb'
require_relative 'db/database.rb'

module CC
  class Request
    include HTTParty

    def initialize(path)
      @path = path
      puts "Path is: #{@path}"
    end

    def fetch
      response = HTTParty.get(full_path)
      response.parsed_response
    end

    def for_category(category)
      self.class.new(@path + "&cat=#{category}")
    end

    def depth(depth)
      self.class.new(@path + "&depth=#{depth}")
    end

    def limit(limit)
      self.class.new(@path + "&limit=#{limit}")
    end

    private

    def full_path
      "http://api.shopstyle.co.uk/api/v2#{@path}"
    end
  end

  def self.products
    Request.new('/products?pid=TEST')
  end

  def self.categories
    Request.new('/categories?pid=TEST')
  end

  def self.women_categories
    Request.new('/categories?pid=TEST').for_category('womens-clothes').depth(1)
  end

  def self.men_categories
    Request.new('/categories?pid=TEST').for_category('mens-clothes').depth(1)
  end

  def self.colors
    Request.new('/colors?pid=TEST')
  end

  def self.sizes
    Request.new('/sizes?pid=TEST')
  end

  def self.start
    Db::Database.start_with_new do
      puts "--- start ---"
      Core::Worker.work!(:women)
      Core::Worker.work!(:men)
      puts "--- finish ---"
    end
  end
end

CC.start
