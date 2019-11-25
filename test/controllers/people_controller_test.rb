require 'test_helper'

class PeopleControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    @person = people(:one)
    @person_without_assignments = people(:person_without_assignments)
  end

  test "authenticated user should get index" do
    # TODO: log in as authenticated user
    sign_in users(:one)
    get people_url
    assert_response :success
  end
  test "unauthenticated user should not get index" do
    get people_url
    
    assert_response :redirect
  end  
  test "should get new" do
    sign_in users(:admin)
    get new_person_url
    assert_response :success
  end

  test "should create person" do
    sign_in users(:admin)
    assert_difference('Person.count') do
      post people_url, params: { person: { name: @person.name, role: @person.role } }
    end

    assert_redirected_to person_url(Person.last)
  end

  test "should show person" do
    sign_in users(:one)
    get person_url(@person)
    assert_response :success
  end

  test "should get edit" do
    sign_in users(:admin)
    get edit_person_url(@person)
    assert_response :success
  end

  test "should update person" do
    sign_in users(:admin)
    patch person_url(@person), params: { person: { name: @person.name, role: @person.role } }
    assert_redirected_to person_url(@person)
  end

  test "should destroy person without assignments" do
    sign_in users(:admin)
    assert_difference('Person.count', -1) do
      delete person_url(@person_without_assignments)
    end

    assert_redirected_to people_url
  end
end
