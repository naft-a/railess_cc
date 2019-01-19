module Objects
  class Size
    def initialize(params = {})
      @name = params[:name]
      @canonicalSize = params[:cannonical_size]
    end

    attr_accessor *self.new.instance_variables.map {|s| s[1..-1]}

    def self.from_api(size)
      params = {
        name: size["name"],
        canonicalSize: size["canonicalSize"].nil? ? nil : size["canonicalSize"]["name"],
      }

      new(params)
    end
  end
end