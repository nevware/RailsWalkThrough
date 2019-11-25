require 'test_helper'

class AssignmentsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @assignment = assignments(:one)
    @assignment_no_timesheets = assignments(:no_timesheets)
  end

  test "should get index" do
    sign_in users(:one)
    get assignments_url
    assert_response :success
  end

  test "should get new" do
    sign_in users(:admin)
    get new_assignment_url
    assert_response :success
  end

  test "should create assignment" do
    sign_in users(:admin)
    assert_difference('Assignment.count') do
      post assignments_url, params: { assignment: { end_date: @assignment.end_date, person_id: @assignment.person_id, project_id: @assignment.project_id, start_date: @assignment.start_date } }
    end

    assert_redirected_to assignment_url(Assignment.last)
  end

  test "should show assignment" do
    sign_in users(:one)
    get assignment_url(@assignment)
    assert_response :success
  end

  test "should get edit" do
    sign_in users(:admin)
    get edit_assignment_url(@assignment)
    assert_response :success
  end

  test "should update assignment" do
    sign_in users(:admin)
    patch assignment_url(@assignment), params: { assignment: { end_date: @assignment.end_date, person_id: @assignment.person_id, project_id: @assignment.project_id, start_date: @assignment.start_date } }
    assert_redirected_to assignment_url(@assignment)
  end

  test "should destroy assignment without timesheets" do
    sign_in users(:admin)
    assert_difference('Assignment.count', -1) do
      delete assignment_url(@assignment_no_timesheets)
    end

    assert_redirected_to assignments_url
  end
  test "should not destroy assignment with timesheets" do
    sign_in users(:admin)
    assert_raise(ActiveRecord::DeleteRestrictionError) do
      delete client_url(@assignment)
    end
  end
end
