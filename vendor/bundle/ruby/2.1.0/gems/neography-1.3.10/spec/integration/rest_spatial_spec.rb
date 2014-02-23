require 'spec_helper'

describe Neography::Rest do
  before(:each) do
    @neo = Neography::Rest.new
  end

  describe "find the spatial plugin" do
    it "can get a description of the spatial plugin" do
      si = @neo.get_spatial
      si.should_not be_nil
      si["graphdb"]["addEditableLayer"].should_not be_nil
    end
  end

  describe "add a point layer" do
    it "can add a simple point layer" do
      pl = @neo.add_point_layer("restaurants") 
      pl.should_not be_nil
      pl.first["data"]["layer"].should == "restaurants"
      pl.first["data"]["geomencoder_config"].should == "lon:lat"
    end

    it "can add a simple point layer with lat and long" do
      pl = @neo.add_point_layer("coffee_shops", "latitude", "longitude") 
      pl.should_not be_nil
      pl.first["data"]["layer"].should == "coffee_shops"
      pl.first["data"]["geomencoder_config"].should == "longitude:latitude"
    end
  end

  describe "add an editable layer" do
    it "can add an editable layer" do
      el = @neo.add_editable_layer("zipcodes", "WKT", "wkt") 
      el.should_not be_nil
      el.first["data"]["layer"].should == "zipcodes"
      el.first["data"]["geomencoder_config"].should == "wkt"
    end
  end

  describe "get a spatial layer" do
    it "can get a layer" do
      sl = @neo.get_layer("restaurants")
      sl.should_not be_nil
      sl.first["data"]["layer"].should == "restaurants"
    end
  end

  describe "create a spatial index" do
    it "can create a spatial index" do
      index = @neo.create_spatial_index("restaurants")
      index["provider"].should == "spatial"
      index["geometry_type"].should == "point"
      index["lat"].should == "lat"
      index["lon"].should == "lon"
    end
  end

  describe "add geometry to spatial layer" do
    it "can add a geometry" do
      geometry = "LINESTRING (15.2 60.1, 15.3 60.1)"
      geo = @neo.add_geometry_to_layer("zipcodes", geometry)
      geo.should_not be_nil
      geo.first["data"]["wkt"].should == geometry
    end
  end

  describe "update geometry from spatial layer" do
    it "can update a geometry" do
      geometry = "LINESTRING (15.2 60.1, 15.3 60.1)"
      geo = @neo.add_geometry_to_layer("zipcodes", geometry)
      geo.should_not be_nil
      geo.first["data"]["wkt"].should == geometry
      geometry = "LINESTRING (14.7 60.1, 15.3 60.1)"
      existing_geo = @neo.edit_geometry_from_layer("zipcodes", geometry, geo)
      existing_geo.first["data"]["wkt"].should == geometry
      existing_geo.first["self"].split('/').last.to_i.should ==  geo.first["self"].split('/').last.to_i 
    end
  end

  describe "add a node to a layer" do
    it "can add a node to a simple point layer" do
      properties = {:name => "Max's Restaurant", :lat => 41.8819, :lon => 87.6278}
      node = @neo.create_node(properties)
      node.should_not be_nil
      added = @neo.add_node_to_layer("restaurants", node)
      added.first["data"]["lat"].should == properties[:lat]
      added.first["data"]["lon"].should == properties[:lon]

      added = @neo.add_node_to_index("restaurants", "dummy", "dummy", node)
      added["data"]["lat"].should == properties[:lat]
      added["data"]["lon"].should == properties[:lon]
    end
  end
  
  describe "find geometries in a bounding box" do
    it "can find a geometry in a bounding box" do
      properties = {:name => "Max's Restaurant", :lat => 41.8819, :lon => 87.6278}
      node = @neo.find_geometries_in_bbox("restaurants", 87.5, 87.7, 41.7, 41.9)
      node.should_not be_empty
      node.first["data"]["lat"].should == properties[:lat]
      node.first["data"]["lon"].should == properties[:lon]
      node.first["data"]["name"].should == "Max's Restaurant"
    end
    
    it "can find a geometry in a bounding box using cypher" do
      properties = {:lat => 60.1, :lon => 15.2}
      @neo.create_spatial_index("geombbcypher", "point", "lat", "lon")
      node = @neo.create_node(properties)
      added = @neo.add_node_to_index("geombbcypher", "dummy", "dummy", node)
      existing_node = @neo.execute_query("start node = node:geombbcypher('bbox:[15.0,15.3,60.0,60.2]') return node")
      existing_node.should_not be_empty
      existing_node["data"][0][0]["data"]["lat"].should == properties[:lat]
      existing_node["data"][0][0]["data"]["lon"].should == properties[:lon]
    end

    it "can find a geometry in a bounding box using cypher two" do
      properties = {:lat => 60.1, :lon => 15.2}
      @neo.create_spatial_index("geombbcypher2", "point", "lat", "lon")
      node = @neo.create_node(properties)
      added = @neo.add_node_to_spatial_index("geombbcypher2", node)
      existing_node = @neo.execute_query("start node = node:geombbcypher2('bbox:[15.0,15.3,60.0,60.2]') return node")
      existing_node.should_not be_empty
      existing_node["data"][0][0]["data"]["lat"].should == properties[:lat]
      existing_node["data"][0][0]["data"]["lon"].should == properties[:lon]
    end

  end

  describe "find geometries within distance" do
    it "can find a geometry within distance" do
      properties = {:name => "Max's Restaurant", :lat => 41.8819, :lon => 87.6278}
      node = @neo.find_geometries_within_distance("restaurants", 87.627, 41.881, 10)
      node.should_not be_empty
      node.first["data"]["lat"].should == properties[:lat]
      node.first["data"]["lon"].should == properties[:lon]
      node.first["data"]["name"].should == "Max's Restaurant"
    end

    it "can find a geometry within distance using cypher" do
      properties = {:lat => 60.1, :lon => 15.2}
      @neo.create_spatial_index("geowdcypher", "point", "lat", "lon")
      node = @neo.create_node(properties)
      added = @neo.add_node_to_index("geowdcypher", "dummy", "dummy", node)
      existing_node = @neo.execute_query("start n = node:geowdcypher({bbox}) return n", {:bbox => "withinDistance:[60.0,15.0,100.0]"})
      existing_node.should_not be_empty
      existing_node.should_not be_empty
      existing_node["data"][0][0]["data"]["lat"].should == properties[:lat]
      existing_node["data"][0][0]["data"]["lon"].should == properties[:lon]
    end

    it "can find a geometry within distance using cypher 2"  do
      properties = {:lat => 60.1, :lon => 15.2}
      @neo.create_spatial_index("geowdcypher2", "point", "lat", "lon")
      node = @neo.create_node(properties)
      added = @neo.add_node_to_spatial_index("geowdcypher2", node)
      existing_node = @neo.execute_query("start n = node:geowdcypher2({bbox}) return n", {:bbox => "withinDistance:[60.0,15.0,100.0]"})
      existing_node.should_not be_empty
      existing_node.should_not be_empty
      existing_node["data"][0][0]["data"]["lat"].should == properties[:lat]
      existing_node["data"][0][0]["data"]["lon"].should == properties[:lon]
    end

  end
  
end