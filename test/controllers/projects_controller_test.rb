require 'test_helper'

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @project = projects(:one)
    @project_without_assignments = projects(:project_without_assignments)
    
  end

  test "authorized user should get index" do
    sign_in users(:one)
    get projects_url
    assert_response :success
  end

  test "unauthenticated user should not get index" do
    get projects_url
    
    assert_response :redirect
  end 
  
  test "should get new" do
    sign_in users(:admin)

    get new_project_url
    assert_response :success
  end

  test "should create project" do
    sign_in users(:admin)
    @person = people(:one)
      assert_difference('Project.count') do
      post projects_url, params: { project: { client_id: @project.client_id, name: @project.name, status: @project.status } }
    end

    assert_redirected_to project_url(Project.last)
  end

  test "should show project" do
    sign_in users(:admin)
    
    @person = people(:one)
    get project_url(@project)
    assert_response :success
  end

  test "should get edit" do
    sign_in users(:admin)
    
    get edit_project_url(@project)
    assert_response :success
  end

  test "should update project" do
    sign_in users(:admin)
    
    patch project_url(@project), params: { project: { client_id: @project.client_id, name: @project.name, status: @project.status } }
    assert_redirected_to project_url(@project)
  end

  test "should destroy project withtout assignements" do
    sign_in users(:admin)
    
    assert_difference('Project.count', -1) do
      delete project_url(@project_without_assignments)
    end

    assert_redirected_to projects_url
  end
  test "should not destroy project with assignments" do
    sign_in users(:admin)
    
    assert_raise(ActiveRecord::DeleteRestrictionError) do
      delete project_url(@project)
    end
  end
end
