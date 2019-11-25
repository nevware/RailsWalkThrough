require 'test_helper'

class TimesheetsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    @timesheet = timesheets(:one)
  end

  test "authenticated user should get index" do
    # TODO: log in as authenticated user
    sign_in users(:admin)
    get timesheets_url
    assert_response :success
  end
  
  test "unauthenticated user should not get index" do
    # TODO: log in as authenticated user
    get timesheets_url
    assert_response :redirect
  end
  

  test "should get new" do
    sign_in users(:admin)
    get new_timesheet_url
    assert_response :success
  end

  test "should create timesheet" do
    sign_in users(:admin)
    assert_difference('Timesheet.count') do
      post timesheets_url, params: { timesheet: { amount: @timesheet.amount, assignment_id: @timesheet.assignment_id, end_date: @timesheet.end_date, start_date: @timesheet.start_date, status: @timesheet.status, unit: @timesheet.unit } }
    end

    assert_redirected_to timesheet_url(Timesheet.last)
  end

  test "should show timesheet" do
    sign_in users(:admin)
    get timesheet_url(@timesheet)
    assert_response :success
  end

  test "should get edit" do
    sign_in users(:admin)
    get edit_timesheet_url(@timesheet)
    assert_response :success
  end

  test "should update timesheet" do
    sign_in users(:admin)
    patch timesheet_url(@timesheet), params: { timesheet: { amount: @timesheet.amount, assignment_id: @timesheet.assignment_id, end_date: @timesheet.end_date, start_date: @timesheet.start_date, status: @timesheet.status, unit: @timesheet.unit } }
    assert_redirected_to timesheet_url(@timesheet)
  end

  test "should destroy timesheet" do
    sign_in users(:admin)
    assert_difference('Timesheet.count', -1) do
      delete timesheet_url(@timesheet)
    end

    assert_redirected_to timesheets_url
  end
end
