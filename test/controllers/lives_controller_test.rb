require 'test_helper'

class LivesControllerTest < ActionDispatch::IntegrationTest
  test "standard data query" do
    get lives_url(:server_id => 17, :start_time => 1601539123, :end_time => 1601661523, :limit => 1)
    assert_response :success
  end

  test "eve query" do
    get lives_url(:server_id => 17, :start_time => 1601539123, :end_time => 1601661523, :limit => 1, :chain => 1)
    assert_response :success
  end

  test "name search" do
    get lives_url(:q => 'POLY DONA', :limit => 1)
    assert_response :success
  end

  test "hash search" do
    get lives_url(:q => 'e45aa4e489b35b6b0fd9f59f0049c688237a9a86', :limit => 1)
    assert_response :success
  end


end
