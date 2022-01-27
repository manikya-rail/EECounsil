require "application_system_test_case"

class PaymentPlansTest < ApplicationSystemTestCase
  setup do
    @payment_plan = payment_plans(:one)
  end

  test "visiting the index" do
    visit payment_plans_url
    assert_selector "h1", text: "Payment Plans"
  end

  test "creating a Payment plan" do
    visit payment_plans_url
    click_on "New Payment Plan"

    fill_in "Amount", with: @payment_plan.amount
    fill_in "Currency", with: @payment_plan.currency
    fill_in "Description", with: @payment_plan.description
    fill_in "Name", with: @payment_plan.name
    fill_in "User", with: @payment_plan.user_id
    click_on "Create Payment plan"

    assert_text "Payment plan was successfully created"
    click_on "Back"
  end

  test "updating a Payment plan" do
    visit payment_plans_url
    click_on "Edit", match: :first

    fill_in "Amount", with: @payment_plan.amount
    fill_in "Currency", with: @payment_plan.currency
    fill_in "Description", with: @payment_plan.description
    fill_in "Name", with: @payment_plan.name
    fill_in "User", with: @payment_plan.user_id
    click_on "Update Payment plan"

    assert_text "Payment plan was successfully updated"
    click_on "Back"
  end

  test "destroying a Payment plan" do
    visit payment_plans_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Payment plan was successfully destroyed"
  end
end
