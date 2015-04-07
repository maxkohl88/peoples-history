class UsersController < ApplicationController

  before_action :authenticate_user!
  helper_method :current_user

  def show

  end
end
