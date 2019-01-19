module Objects
  class Category
    def initialize(params = {})
      @id = params[:id]
      @name = params[:name]
      @short_name = params[:short_name]
      @full_name = params[:full_name]
      localized_id = params[:localized_id]
    end

    attr_accessor *self.new.instance_variables.map {|s| s[1..-1]}

    def self.from_api(category)
      params = {
        id: category["id"],
        name: category["id"],
        short_name: category["shortName"],
        full_name: category["fullName"],
        localized_id: category["localizedId"]
      }

      new(params)
    end
  end
end