require "test_helper"

class BusinessesTest < ActionDispatch::IntegrationTest
  test "can build a new business" do
    sign_in users(:empty)
    get new_business_path
    assert_response :ok
  end

  test "redirect to edit if building an existing business" do
    user = users(:with_business)
    sign_in user

    get new_business_path

    assert_redirected_to edit_business_path(user.business)
  end

  test "cannot create new business if already has one" do
    sign_in users(:with_business)

    assert_no_difference "Business.count" do
      post businesses_path, params: valid_business_params
    end
  end

  test "redirect to the edit if they already have a business" do
    user = users(:with_business)
    sign_in user

    get new_business_path

    assert_redirected_to edit_business_path(user.business)
  end

  test "successful business creation" do
    user = users(:empty)
    sign_in user

    assert_difference "Business.count", 1 do
      post businesses_path, params: valid_business_params
    end
    assert_equal "basecamp.png", user.business.avatar.filename.to_s
    assert_redirected_to developers_path
  end

  test "successful business creation with a stored location" do
    developer = developers(:available)

    sign_in users(:empty)
    post developer_messages_path(developer)
    assert_redirected_to new_business_path

    assert_difference "Business.count", 1 do
      post businesses_path, params: valid_business_params
    end
    assert_redirected_to developer_messages_path(developer)
  end

  test "successful edit to business" do
    sign_in users(:with_business)
    business = businesses(:one)

    get edit_business_path(business)
    assert_select "form"

    patch business_path(business), params: {
      business: {
        name: "New Owner Name"
      }
    }
    assert_redirected_to developers_path
    follow_redirect!

    assert_equal "New Owner Name", business.reload.name
  end

  test "invalid profile creation" do
    sign_in users(:empty)

    assert_no_difference "Business.count" do
      post businesses_path, params: {
        business: {
          name: "Business"
        }
      }
    end
  end

  test "can edit own business" do
    sign_in users(:with_business)
    business = businesses(:one)

    get edit_business_path(business)
    assert_select "form"

    patch business_path(business), params: {
      business: {
        name: "New Name"
      }
    }
    assert_redirected_to developers_path
    assert_equal "New Name", business.reload.name
  end

  test "cannot edit another business" do
    sign_in users(:with_business)
    business = businesses(:two)

    get edit_business_path(business)
    assert_redirected_to root_path

    assert_no_changes "business.name" do
      patch business_path(business), params: {
        business: {
          name: "New Name"
        }
      }
    end
    assert_redirected_to root_path
  end

  def valid_business_params
    {
      business: {
        name: "Business Owner",
        company: "Business, LLC",
        bio: "We're in the business for business.",
        avatar: fixture_file_upload("basecamp.png", "image/png")
      }
    }
  end
end
