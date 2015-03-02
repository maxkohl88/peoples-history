class SportsController < ApplicationController
  before_action :authenticate_user!

  helper_method :all_sports

  def index
  end

  private

  def all_sports
    @all_sports ||= Sport.all
  end
end