class ResourceCompletionController < ApplicationController
  before_action :private_access

  def create
    @resource = Resource.friendly.find(params[:resource_id])
    @resource.users << current_user unless @resource.users.include? current_user

    respond_to do |format|
      format.html { redirect_to [@resource.course, @resource.next] }
      format.js
    end
  end

  def destroy
    @resource = Resource.friendly.find(params[:resource_id])
    @resource.users.delete(current_user)
  end

end