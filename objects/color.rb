module Objects
  class Color
    def initialize(params = {})
      @name = params[:name]
      @image = params[:image]
    end
    
    attr_accessor *self.new.instance_variables.map {|s| s[1..-1]}

    def self.from_api(color)
      params = {
        name: color.nil? ? nil : color["name"],
        image: color.nil? ? nil :
          color["image"].nil? ? nil : color["image"]["sizes"]["Best"]["url"],
      }

      new(params)
    end
  end
end