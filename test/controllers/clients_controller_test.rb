require 'test_helper'

class ClientsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  
  setup do
    @client = clients(:one)
    @client_no_projects = clients(:no_projects)
  end

  test "should get index" do
    sign_in users(:one)
    get clients_url
    assert_response :success
  end

  test "should get new" do
    sign_in users(:admin)
    get new_client_url
    assert_response :success
  end

  test "should create client" do
    sign_in users(:admin)
    assert_difference('Client.count') do
      post clients_url, params: { client: { name: @client.name, status: @client.status } }
    end

    assert_redirected_to client_url(Client.last)
  end

  test "should show client" do
    sign_in users(:one)
    get client_url(@client)
    assert_response :success
  end

  test "should get edit" do
    sign_in users(:admin)
    get edit_client_url(@client)
    assert_response :success
  end

  test "should update client" do
    sign_in users(:admin)
    patch client_url(@client), params: { client: { name: @client.name, status: @client.status } }
    assert_redirected_to client_url(@client)
  end

  test "should destroy client without projects" do
    sign_in users(:admin)
    assert_difference('Client.count', -1) do
      delete client_url(@client_no_projects)
    end

    assert_redirected_to clients_url
  end
  test "should not destroy client with projects" do
    sign_in users(:admin)
    assert_raise(ActiveRecord::DeleteRestrictionError) do
      delete client_url(@client)
    end
  end
end
