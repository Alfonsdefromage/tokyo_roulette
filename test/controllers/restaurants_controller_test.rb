require "test_helper"

class RestaurantsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get restaurants_new_url
    assert_response :success
  end

  test "should get roulette" do
    get restaurants_roulette_url
    assert_response :success
  end
end
