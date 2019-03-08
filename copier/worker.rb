module Copier
  class Worker
    NOT_TO_COPY = ["bridal", "maternity-clothes", "swimsuits", "teens", "teen-guys-clothes", "mens-swimsuits", "mens-underwear-and-socks"]

    def self.work!(type)
      self.new(type).work
    end

    def initialize(type)
      @type = type
      @categories = categories_from_type
      @to_copy = []
    end

    def categories_from_type
      case @type
      when 'women'
        CC.women_categories.fetch['categories']
      when 'men'
        CC.men_categories.fetch['categories']
      end
    end

    def work
      copy_categories
      copy_sizes
      copy_colors
      copy_products
    end

    def copy_categories
      @categories.each do |category|
        @to_copy << category['id'] unless NOT_TO_COPY.include?(category['id'])
      end
      @to_copy.each do |cc|
        CC.categories.for_category(cc).fetch["categories"].each do |c|
          Db::Database.insert_category(Objects::Category.from_api(c))
        end
      end
    end

    def copy_sizes
      all_sizes = []
      @to_copy.each do |cc|
        CC.sizes.for_category(cc).fetch["sizes"].each do |size|
          all_sizes << Objects::Size.from_api(size)
        end
      end
      all_sizes = all_sizes.uniq{|s| [s.external_id]}
      all_sizes.each do |size|
        Db::Database.insert_size(size)
      end
    end

    def copy_colors
      all_colors = []
      @to_copy.each do |cc|
        CC.colors.for_category(cc).fetch["colors"].each do |color|
          all_colors << Objects::Color.from_api(color)
        end
      end
      all_colors = all_colors.uniq{|c| [c.name] }
      all_colors.each do |color|
        Db::Database.insert_color(color)
      end 
    end

    def copy_products
      products = []
      @to_copy.each do |cc|
        CC.products.for_category(cc).limit(1).fetch["products"].each do |product|
          products << Objects::Product.from_api(product) 
          products.each do |prod|
            prod_id = Db::Database.insert_product(prod)
            category_id = Db::Database.get_category_id_by_identifier(prod.categories.first.identifier)
            unless category_id.nil?
              Db::Database.insert_product_category(prod_id, category_id) 
            end
          end
        end
      end
    end
  end
end