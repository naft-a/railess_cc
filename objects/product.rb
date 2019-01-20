require_relative 'retailer.rb'
require_relative 'brand.rb'
require_relative 'color.rb'
require_relative 'size.rb'
require_relative 'category.rb'

module Objects
  class Product
    def initialize(params = {})
      @external_id = params[:external_id]
      @branded_name = params[:branded_name]
      @unbranded_name = params[:unbranded_name]
      @currency = params[:currency]
      @price = params[:price]
      @price_label = params[:price_label]
      @in_stock = params[:in_stock]
      @click_url = params[:click_url]
      @description = params[:description]
      @image = params[:image]
      @discount = params[:discount]
      @colors = params[:colors]
      @sizes = params[:sizes]
      @categories = params[:categories] 
    end

    attr_accessor *self.new.instance_variables.map {|s| s[1..-1]}

    def self.from_api(product)
      params = {
        external_id: product["id"],
        name: product["name"],
        branded_name: product["brandedName"],
        unbranded_name: product["unbrandedName"],
        currency: product["currency"],
        price: product["price"],
        price_label: product["priceLabel"],
        in_stock: product["inStock"],
        retailer: Retailer.from_api(product["retailer"]),
        brand: Brand.from_api(product["brand"]),
        description: product["description"],
        click_url: product["clickUrl"],
        image: product["image"]["sizes"]["Best"]["url"],
        discount: product["discount"],
        colors: product["colors"]&.map {|c| Color.from_api(c)},
        sizes: product["sizes"]&.map {|s| Size.from_api(s)},
        categories: product["categories"]&.map {|c| Category.from_api(c)}
      }

      new(params)
    end
  end
end