require 'csv'

module Bio
  class Assembly
    class Scaffold
      # An Array of ScaffoldedComponent objects
      attr_accessor :scaffolded_components
      
      def initialize
        @scaffolded_components = []
      end
      
      class ScaffoldedComponent
        attr_accessor :object_id, :object_beg, :object_end, :part_number, :component_type
      end
      
      # non- 'N' or 'U' type components
      class ScaffoldedObject < ScaffoldedComponent
        attr_accessor :component_type, :component_id, :component_begin, :component_end, :orientation
      end
      
      # 'N' or 'U' type components
      class ScaffoldedGap < ScaffoldedComponent
        attr_accessor :gap_length, :gap_type, :linkage
      end
    end
    
    
    class AGP
      def initialize(filename)
        @filename = filename 
      end
      
      # Iterate through scaffolds, yielding a Scaffold object at each point
      def each_scaffold
        scaff = Scaffold.new
        
        CSV.foreach(@filename, :col_sep => "\t") do |row|
          p row
          component = nil
          if %w(N U).include?(row[4])
            component = Bio::Assembly::Scaffold::ScaffoldedGap.new
            
            [:object_id, :object_beg, :object_end, :part_number, :component_type, 
              :gap_length, :gap_type, :linkage].each_with_index do |sym, i|
              answer = row[i]
              answer = answer.to_i if [:object_beg, :object_end, :gap_length].include?(sym)
              component.send("#{sym}=".to_sym, answer)
            end
          else
            component = Bio::Assembly::Scaffold::ScaffoldedObject.new
            
            [:object_id, :object_beg, :object_end, :part_number, :component_type, 
              :component_id, :component_begin, :component_end, :orientation].each_with_index do |sym, i|
              answer = row[i]
              answer = answer.to_i if [:object_beg, :object_end, :component_begin, :component_end].include?(sym)
              component.send("#{sym}=".to_sym, answer)
            end
          end
          unless scaff.object_id == component.object_id
            yield scaff
            scaff = Scaffold.new
          end
          scaff.scaffolded_components.push component
        end
        yield scaff #yield the last scaffold
      end
    end
  end
end