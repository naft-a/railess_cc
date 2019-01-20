module Objects
  class Size
    def initialize(params = {})
      @external_id = params[:external_id]
      @name = params[:name]
      @canonicalSize = params[:cannonical_size]
    end

    attr_accessor *self.new.instance_variables.map {|s| s[1..-1]}

    def self.from_api(size)
      params = {
        external_id: size.nil? ? nil : size["id"],
        name: size.nil? ? nil : size["name"],
        canonicalSize: 
          size.nil? ? nil :
            size["canonicalSize"].nil? ? nil : size["canonicalSize"]["name"],
      }

      new(params)
    end
  end
end