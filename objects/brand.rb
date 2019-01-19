module Objects
  class Brand
    def initialize(params = {})
      @id = params[:id]
      @name = params[:name]
    end

    attr_accessor *self.new.instance_variables.map {|s| s[1..-1]}

    def self.from_api(brand)
      params = {
        id: brand["id"],
        name: brand["name"],
      }

      new(params)
    end
  end
end