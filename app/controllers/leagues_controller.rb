class LeaguesController < ApplicationController

  before_action :authenticate_user!

  def new
    @league = League.new

  end

  def index
  end

  def show
    @league = League.find params[:id]
  end

  def create
    @league = League.new league_params
    @user = current_user
    @membership = Membership.new league: @league, user: @user

    if @league.save && @membership.save
      redirect_to user_path(current_user), notice: 'League and membership saved!'
    else
      render :new
    end
  end

  private

  def league_params
    params.require(:league).permit(:name, :espn_id, :sport_id)
  end
end
