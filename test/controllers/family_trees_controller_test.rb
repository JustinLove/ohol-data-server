require 'test_helper'

class FamilyTreesControllerTest < ActionDispatch::IntegrationTest
  test "standard data query" do
    get family_trees_url(:server_id => 17, :epoch => 2, :playerid => 3389291)
    assert_response :success
  end

  test "official lineage link" do
    get family_trees_url(:server_name => 'bigserver2.onehouronelife.com', :start_time => 1601062838, :end_time => 1601070038, :playerid => 3383692)
    assert_response :success
  end
end
