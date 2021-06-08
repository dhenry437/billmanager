require "test_helper"

class PaydaysControllerTest < ActionDispatch::IntegrationTest
  setup do
    @payday = paydays(:one)
  end

  test "should get index" do
    get paydays_url
    assert_response :success
  end

  test "should get new" do
    get new_payday_url
    assert_response :success
  end

  test "should create payday" do
    assert_difference('Payday.count') do
      post paydays_url, params: { payday: { date: @payday.date, name: @payday.name, recurring: @payday.reccuring } }
    end

    assert_redirected_to payday_url(Payday.last)
  end

  test "should show payday" do
    get payday_url(@payday)
    assert_response :success
  end

  test "should get edit" do
    get edit_payday_url(@payday)
    assert_response :success
  end

  test "should update payday" do
    patch payday_url(@payday), params: { payday: { date: @payday.date, name: @payday.name, recurring: @payday.reccuring } }
    assert_redirected_to payday_url(@payday)
  end

  test "should destroy payday" do
    assert_difference('Payday.count', -1) do
      delete payday_url(@payday)
    end

    assert_redirected_to paydays_url
  end
end
