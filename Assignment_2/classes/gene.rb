require_relative '.\tools.rb'
require_relative '.\annotation.rb'

class Gene
    attr_accessor :id
    attr_accessor :interactions
    attr_accessor :level
    attr_accessor :annotations
  
    def initialize(params={})
      @id = params.fetch(:id, false)
      @level = params.fetch(:level)
      @threshold = params.fetch(:threshold)
      @interactions = Array.new
      get_interactions
    end
  
    def get_interactions
      inter = Tools.get_inter(@id)
      inter.each do |i|
        id1uni, id2uni, c, d, id1, id2, *rest, score = i.split("\t")
        score = score.match(/\d+.\d+/).to_s
        if score.to_f < @threshold
          next
        end
        id1 = id1.match(/A[Tt]\d[Gg]\d\d\d\d\d/).to_s.upcase
        id2 = id2.match(/A[Tt]\d[Gg]\d\d\d\d\d/).to_s.upcase
        if id1.upcase != @id.upcase # Some gene positions in intact are swapped
            id1, id2 = id2, id1
        end
        if id1 == id2 or id2 == "" # Dont save this interaction if its with itself or with a non Arabidopsis gene
          next
        end
        @interactions |= [[@id, id2, score]]
      end
    end

    def annotate
      @annotations = Annotation.new(@id)
  end
end
  