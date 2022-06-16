require 'test_helper'

class InventoryGroupsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get inventory_groups_index_url
    assert_response :success
  end

  test "should get edit" do
    get inventory_groups_edit_url
    assert_response :success
  end

  test "should get new" do
    get inventory_groups_new_url
    assert_response :success
  end

  test "should get show" do
    get inventory_groups_show_url
    assert_response :success
  end

end
