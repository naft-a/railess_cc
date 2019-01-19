module Objects
  class Retailer
    def initialize(params = {})
      @id = params[:id]
      @name = params[:name]
      @itp_compatible = params[:itp_compatible]
      @score = params[:score]
    end

    attr_accessor *self.new.instance_variables.map {|s| s[1..-1]}

    def self.from_api(retailer)
      params = {
        id: retailer["id"],
        name: retailer["name"],
        itp_compatible: retailer["itpCompatible"],
        score: retailer["score"],
      }

      new(params)
    end
  end
end