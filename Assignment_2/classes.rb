class Dogo
    attr_accessor :name
    def initialize(params={})
        @name = params.fetch(:name)
    end
end