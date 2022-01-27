require 'test_helper'

class PaymentPlansControllerTest < ActionDispatch::IntegrationTest
  setup do
    @payment_plan = payment_plans(:one)
  end

  test "should get index" do
    get payment_plans_url
    assert_response :success
  end

  test "should get new" do
    get new_payment_plan_url
    assert_response :success
  end

  test "should create payment_plan" do
    assert_difference('PaymentPlan.count') do
      post payment_plans_url, params: { payment_plan: { amount: @payment_plan.amount, currency: @payment_plan.currency, description: @payment_plan.description, name: @payment_plan.name, user_id: @payment_plan.user_id } }
    end

    assert_redirected_to payment_plan_url(PaymentPlan.last)
  end

  test "should show payment_plan" do
    get payment_plan_url(@payment_plan)
    assert_response :success
  end

  test "should get edit" do
    get edit_payment_plan_url(@payment_plan)
    assert_response :success
  end

  test "should update payment_plan" do
    patch payment_plan_url(@payment_plan), params: { payment_plan: { amount: @payment_plan.amount, currency: @payment_plan.currency, description: @payment_plan.description, name: @payment_plan.name, user_id: @payment_plan.user_id } }
    assert_redirected_to payment_plan_url(@payment_plan)
  end

  test "should destroy payment_plan" do
    assert_difference('PaymentPlan.count', -1) do
      delete payment_plan_url(@payment_plan)
    end

    assert_redirected_to payment_plans_url
  end
end
