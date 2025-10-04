class ProfilesController < ApplicationController
  before_action :require_login
  before_action :set_profile, only: [:show, :edit, :update, :destroy, :analytics]
  
  def index
    @profiles = current_user.profiles
  end

  def show
  end

  def new
    @profile = Profile.new
  end

  def create
    @profile = current_user.profiles.build(profile_params)
    
    if @profile.save
      redirect_to profiles_path, notice: 'Profile was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @profile.update(profile_params)
      redirect_to profiles_path, notice: 'Profile was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @profile.destroy
    redirect_to profiles_path, notice: 'Profile was successfully deleted.'
  end

  def analytics
    @total_views = @profile.total_views
    @right_swipes = @profile.right_swipes
    @left_swipes = @profile.left_swipes
    @swipe_right_rate = @profile.swipe_right_rate
    @average_time_spent = @profile.average_time_spent
    @average_scroll_depth = @profile.average_scroll_depth
    @interactions = @profile.profile_interactions.order(created_at: :desc).limit(50)
  end
  
  private
  
  def set_profile
    @profile = current_user.profiles.find(params[:id])
  end
  
  def profile_params
    params.require(:profile).permit(:name, :age, :description, :height, :income_level, :gender_identity, :active, images: [])
  end
end
