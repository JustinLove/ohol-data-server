require 'test_helper'

class FamilyTreesControllerTest < ActionDispatch::IntegrationTest
  test "standard data query" do
    get family_trees_url(:server_id => 17, :epoch => 2, :playerid => 3389291)
    assert_response :success
  end
end
