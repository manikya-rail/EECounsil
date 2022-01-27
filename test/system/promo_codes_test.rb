require "application_system_test_case"

class PromoCodesTest < ApplicationSystemTestCase
  setup do
    @promo_code = promo_codes(:one)
  end

  test "visiting the index" do
    visit promo_codes_url
    assert_selector "h1", text: "Promo Codes"
  end

  test "creating a Promo code" do
    visit promo_codes_url
    click_on "New Promo Code"

    fill_in "Code", with: @promo_code.code
    fill_in "Type", with: @promo_code.type
    fill_in "Value", with: @promo_code.value
    click_on "Create Promo code"

    assert_text "Promo code was successfully created"
    click_on "Back"
  end

  test "updating a Promo code" do
    visit promo_codes_url
    click_on "Edit", match: :first

    fill_in "Code", with: @promo_code.code
    fill_in "Type", with: @promo_code.type
    fill_in "Value", with: @promo_code.value
    click_on "Update Promo code"

    assert_text "Promo code was successfully updated"
    click_on "Back"
  end

  test "destroying a Promo code" do
    visit promo_codes_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Promo code was successfully destroyed"
  end
end
