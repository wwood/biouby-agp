require 'helper'
require 'tempfile'

class TestBioAgp < Test::Unit::TestCase
  should "parse ok" do
    test = "##agp-version  2.0
# ORGANISM: Homo sapiens
# TAX_ID: 9606
# ASSEMBLY NAME: EG1
# ASSEMBLY DATE: 09-November-2011
# GENOME CENTER: NCBI
# DESCRIPTION: Example AGP specifying the assembly of scaffolds from WGS contigs
EG1_scaffold1 1 3043  1 W AADB02037551.1  1 3043  +
EG1_scaffold2 1 40448 1 W AADB02037552.1  1 40448 +
EG1_scaffold2 40449 40661 2 N 213 scaffold  yes paired-ends
EG1_scaffold2 40662 117642  3 W AADB02037553.1  1 76981 +
EG1_scaffold2 117643  117718  4 N 76  scaffold  yes paired-ends
EG1_scaffold2 117719  145387  5 W AADB02037554.1  1 27669 +
EG1_scaffold2 145388  145485  6 N 98  scaffold  yes paired-ends".split("\n").collect{|s| s.strip.gsub(/\s+/,"\t")}.join("\n")


    Tempfile.open('a') do |tempfile|
      tempfile.puts test
      tempfile.close
      
      agm = Bio::Assembly::AGP.new(tempfile.path)
      scaffold_names = ['EG1_scaffold1', 'EG1_scaffold2']
      num_objects = [1, 6]
      i = 0
      agm.each_scaffold do |scaffold|
        assert_kind_of Bio::Assembly::Scaffold, scaffold
        assert_kind_of Array, scaffold.scaffolded_components
        assert_kind_of Bio::Assembly::Scaffold::ScaffoldedObject, scaffold.scaffolded_components[0]
        assert_equal scaffold_names[i], scaffold.scaffolded_components[0].object_id
        assert_equal num_objects[i], scaffold.scaffolded_components.length
        fail
        i += 1
      end
      assert_equal 2, i, 'correct number of scaffolds parsed'
    end
  end
end
