require 'test_helper'

class StockAdjustmentsControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get stock_adjustments_edit_url
    assert_response :success
  end

  test "should get new" do
    get stock_adjustments_new_url
    assert_response :success
  end

  test "should get create" do
    get stock_adjustments_create_url
    assert_response :success
  end

  test "should get update" do
    get stock_adjustments_update_url
    assert_response :success
  end

  test "should get destroy" do
    get stock_adjustments_destroy_url
    assert_response :success
  end

end
