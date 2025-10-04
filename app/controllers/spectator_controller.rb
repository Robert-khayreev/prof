class SpectatorController < ApplicationController
  before_action :ensure_viewer_session
  
  def index
    # Get list of profiles the user hasn't seen yet in this session
    seen_profile_ids = session[:seen_profile_ids] || []
    
    # Build base query - exclude user's own profiles if logged in
    query = Profile.where(active: true)
    query = query.where.not(user_id: current_user.id) if logged_in?
    
    @profile = query.where.not(id: seen_profile_ids)
                    .order("RANDOM()")
                    .first
    
    if @profile
      # Mark as seen (tracking happens on swipe action with complete data)
      session[:seen_profile_ids] = (seen_profile_ids + [@profile.id]).uniq
    else
      # All profiles have been seen, reset
      session[:seen_profile_ids] = []
    end
    
    # Calculate remaining count - exclude user's own profiles if logged in
    remaining_query = Profile.where(active: true).where.not(id: seen_profile_ids + [@profile&.id].compact)
    remaining_query = remaining_query.where.not(user_id: current_user.id) if logged_in?
    @remaining_count = remaining_query.count
  end

  def show
    @profile = Profile.find(params[:id])
    
    # Redirect if user is trying to view their own profile
    if logged_in? && @profile.user_id == current_user.id
      redirect_to spectator_index_path, alert: "You cannot view your own profile in spectator mode."
      return
    end
    
    # Tracking happens when user swipes with complete data
  end

  def track
    @profile = Profile.find(params[:id])
    
    # Don't track interactions on user's own profile
    if logged_in? && @profile.user_id == current_user.id
      Rails.logger.info "❌ Blocked tracking own profile: #{@profile.id} by user #{current_user.id}"
      head :forbidden
      return
    end
    
    interaction = ProfileInteraction.create(
      profile: @profile,
      viewer_session: session[:viewer_session],
      action: params[:action_type],
      time_spent: params[:time_spent],
      scroll_depth: params[:scroll_depth],
      image_index: params[:image_index]
    )
    
    if interaction.persisted?
      Rails.logger.info "✅ Tracked #{params[:action_type]} for profile #{@profile.id} (#{@profile.name})"
    else
      Rails.logger.error "❌ Failed to track: #{interaction.errors.full_messages.join(', ')}"
    end
    
    head :ok
  end
  
  def reset
    session[:seen_profile_ids] = []
    redirect_to spectator_index_path, notice: "Starting over! All profiles are available again."
  end
  
  private
  
  def ensure_viewer_session
    session[:viewer_session] ||= SecureRandom.urlsafe_base64
  end
end
