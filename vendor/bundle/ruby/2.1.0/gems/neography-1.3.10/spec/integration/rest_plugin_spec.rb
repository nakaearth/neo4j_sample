# Encoding: utf-8

require 'spec_helper'

describe Neography::Rest do
  before(:each) do
    @neo = Neography::Rest.new
  end

  describe "execute gremlin script" do
    it "can get the root node id", :gremlin => true do
      root_node = @neo.execute_script("g.v(0)")
      root_node.should have_key("self")
      root_node["self"].split('/').last.should == "0"
    end

    it "can get the a node", :gremlin => true do
      new_node = @neo.create_node
      id = new_node["self"].split('/').last
      existing_node = @neo.execute_script("g.v(#{id})")
      existing_node.should_not be_nil
      existing_node.should have_key("self")
      existing_node["self"].split('/').last.should == id
    end

    it "can get the a node with a variable", :gremlin => true do
      new_node = @neo.create_node
      id = new_node["self"].split('/').last
      existing_node = @neo.execute_script("g.v(id)", {:id => id.to_i})
      existing_node.should_not be_nil
      existing_node.should have_key("self")
      existing_node["self"].split('/').last.should == id
    end
  end

  describe "execute cypher query" do
    it "can get the root node id" do
      root_node = @neo.execute_query("start n=node(0) return n")
      root_node.should have_key("data")
      root_node.should have_key("columns")
      root_node["data"][0][0].should have_key("self")
      root_node["data"][0][0]["self"].split('/').last.should == "0"
    end

    it "can get the a node" do
      new_node = @neo.create_node
      id = new_node["self"].split('/').last
      existing_node = @neo.execute_query("start n=node(#{id}) return n")
      existing_node.should_not be_nil
      existing_node.should have_key("data")
      existing_node.should have_key("columns")
      existing_node["data"][0][0].should have_key("self")
      existing_node["data"][0][0]["self"].split('/').last.should == id
    end

    it "can perform a range query" do
      name = generate_text(6)
      new_node = @neo.create_node({:number => 3})
      id = new_node["self"].split('/').last
      @neo.create_node_index(name, "fulltext","lucene")
      @neo.add_node_to_index(name, "number", 3, new_node) 
      existing_node = @neo.find_node_index(name, "number:[1 TO 5]")
      existing_node.first["self"].should == new_node["self"]
      existing_node.first.should_not be_nil
      existing_node.first["data"]["number"].should == 3
      existing_node = @neo.execute_query("start n=node:#{name}(\"number:[1 TO 5]\") return n")
      existing_node.should have_key("data")
      existing_node.should have_key("columns")
      existing_node["data"][0][0].should have_key("self")
      existing_node["data"][0][0]["self"].split('/').last.should == id
    end

    it "can perform a range query with a term" do
      name = generate_text(6)
      new_node = @neo.create_node({:number => 3, :name => "Max"})
      id = new_node["self"].split('/').last
      @neo.create_node_index(name, "fulltext","lucene")
      @neo.add_node_to_index(name, "number", 3, new_node) 
      @neo.add_node_to_index(name, "name", "max", new_node) 
      existing_node = @neo.find_node_index(name, "name:max AND number:[1 TO 5]")
      existing_node.first["self"].should == new_node["self"]
      existing_node.first.should_not be_nil
      existing_node.first["data"]["number"].should == 3
      existing_node.first["data"]["name"].should == "Max"
      existing_node = @neo.execute_query("start n=node:#{name}(\"name:max AND number:[1 TO 5]\") return n")
      existing_node.should have_key("data")
      existing_node.should have_key("columns")
      existing_node["data"][0][0].should have_key("self")
      existing_node["data"][0][0]["self"].split('/').last.should == id
    end


    it "can get a node with a tilde" do
      new_node = @neo.create_node("name" => "Ateísmo Sureño")
      id = new_node["self"].split('/').last
      existing_node = @neo.execute_query("start n=node(#{id}) return n")
      existing_node.should_not be_nil
      existing_node.should have_key("data")
      existing_node.should have_key("columns")
      existing_node["data"][0][0]["self"].split('/').last.should == id
      existing_node["data"][0][0]["data"]["name"].should == "Ateísmo Sureño"
    end

    it "can get the a node with a variable" do
      new_node = @neo.create_node
      id = new_node["self"].split('/').last
      existing_node = @neo.execute_query("start n=node({id}) return n", {:id => id.to_i})
      existing_node.should_not be_nil
      existing_node.should have_key("data")
      existing_node.should have_key("columns")
      existing_node["data"][0][0].should have_key("self")
      existing_node["data"][0][0]["self"].split('/').last.should == id
    end

    it "can get the stats of a cypher query" do
      root_node = @neo.execute_query("start n=node(0) return n", nil, {:stats => true})
      root_node.should have_key("data")
      root_node.should have_key("columns")
      root_node.should have_key("stats")
      root_node["data"][0][0].should have_key("self")
      root_node["data"][0][0]["self"].split('/').last.should == "0"
    end

    it "can get the profile of a cypher query" do
      root_node = @neo.execute_query("start n=node(0) return n", nil, {:profile => true})
      root_node.should have_key("data")
      root_node.should have_key("columns")
      root_node.should have_key("plan")
      root_node["data"][0][0].should have_key("self")
      root_node["data"][0][0]["self"].split('/').last.should == "0"
    end

    it "can get the stats and profile of a cypher query" do
      root_node = @neo.execute_query("start n=node(0) return n", nil, {:stats => true, :profile => true})
      root_node.should have_key("data")
      root_node.should have_key("columns")
      root_node.should have_key("stats")
      root_node.should have_key("plan")
      root_node["data"][0][0].should have_key("self")
      root_node["data"][0][0]["self"].split('/').last.should == "0"
    end


    it "can delete everything but start node", :reference => true do
      @neo.execute_query("START n=node(*) MATCH n-[r?]-() WHERE ID(n) <> 0 DELETE n,r")
      expect {
        @neo.execute_query("start n=node({id}) return n", {:id => 1})
      }.to raise_error(Neography::BadInputException)
      root_node = @neo.execute_query("start n=node({id}) return n", {:id => 0})
      root_node.should_not be_nil
    end

    it "throws an error for an invalid query" do
      expect {
        @neo.execute_query("this is not a query")
      }.to raise_error(Neography::SyntaxException)
    end

    it "throws an error for not unique paths in unique path creation" do
      node1 = @neo.create_node
      node2 = @neo.create_node

      id1 = node1["self"].split('/').last.to_i
      id2 = node2["self"].split('/').last.to_i

      # create two 'FOO' relationships
      @neo.execute_query("START a=node({id1}), b=node({id2}) CREATE a-[r:FOO]->b RETURN r", { :id1 => id1, :id2 => id2 })
      @neo.execute_query("START a=node({id1}), b=node({id2}) CREATE a-[r:FOO]->b RETURN r", { :id1 => id1, :id2 => id2 })

      expect {
        @neo.execute_query("START a=node({id1}), b=node({id2}) CREATE UNIQUE a-[r:FOO]->b RETURN r", { :id1 => id1, :id2 => id2 })
      }.to raise_error(Neography::UniquePathNotUniqueException)
    end

  end

end
