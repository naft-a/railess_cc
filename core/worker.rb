module Core
  class Worker
    CATEGORY_TYPES = ['men_categories', 'women_categories']
    BANNED = ["bridal", "maternity-clothes", "swimsuits", "teens", "teen-guys-clothes", "mens-swimsuits", "mens-underwear-and-socks", "petites", "plus-sizes"]

    def self.work!(type)
      self.new(type).work
    end

    def initialize(type)
      @raw_type = type.to_s
      @type = "#{@raw_type}_categories"
      @categories = available_categories
    end

    def work
      copy_categories
      copy_sizes 
      copy_colors unless @raw_type == "men"
      copy_products
    end

    def copy_categories
      @categories.each do |cc|
        CC.categories.for_category(cc).fetch["categories"].each do |c|
          Db::Database.insert_category(Objects::Category.from_api(c), @raw_type)
        end
      end
    end

    def copy_sizes
      _all_sizes = []
      @categories.each do |cc|
        CC.sizes.for_category(cc).fetch["sizes"].each do |size|
          _all_sizes << Objects::Size.from_api(size)
        end
      end
      _all_sizes = _all_sizes.uniq{|s| [s.external_id]}
      _all_sizes.each do |size|
        Db::Database.insert_size(size)
      end
    end

    def copy_colors
      _all_colors = []
      @categories.each do |cc|
        CC.colors.for_category(cc).fetch["colors"].each do |color|
          _all_colors << Objects::Color.from_api(color)
        end
      end
      _all_colors = _all_colors.uniq{|c| [c.name] }
      _all_colors.each do |color|
        Db::Database.insert_color(color)
      end 
    end

    def copy_products
      @categories.each do |cc|
        CC.products.for_category(cc).limit(50).fetch["products"].each do |product|
          prod = Objects::Product.from_api(product)
          color_id = Db::Database.get_color_id_by_name(prod&.colors&.first&.name&.capitalize || '')
          prod_id = Db::Database.insert_product(prod, color_id)
          category_id = Db::Database.get_category_id_by_identifier(prod.categories.first.identifier)
          unless category_id.nil?
            Db::Database.insert_product_category(prod_id, category_id) 
          end

          _size_ids = []
          prod.sizes.each do |s|
            _size_ids << Db::Database.get_size_id_by_name(s.name)
          end

          _size_ids.compact.each do |sid|
            Db::Database.insert_product_size(prod_id, sid)
          end
        end
      end
    end

    private

    # returns Array of categories
    def available_categories
      categories = CC.send(@type).fetch['categories'].map do |cc|
        cc['id'] unless BANNED.include?(cc['id'])
      end.compact

      categories
    end
  end
end