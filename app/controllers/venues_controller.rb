class VenuesController < ApplicationController
  respond_to :html,:json
  before_filter :login_required, :except => [:index, :show,:records]
  before_filter :find_venue, :except => [:index,:new,:create]
  
  def index
    if params[:user_id].present?
      @venues = User.find(params[:user_id]).records.map(&:venue)
    else
      @venues = Venue.all
    end
    respond_with(@venues)
  end
  
  def new
    if params[:latitude].blank? || params[:longitude].blank?
      redirect_to geos_path
    else
      @venue = Venue.new(:latitude => params[:latitude],:longitude => params[:longitude],:geo_id => params[:geo_id],:zoom_level => params[:zoom_level])
    end
  end

  def create
    @venue = Venue.new(params[:venue])
    @venue.creator = current_user
    flash[:notice] = 'Venue was successfully created.' if @venue.save
    respond_with(@venue)
  end
  
  def show
    @timeline = @venue.callings
    @timeline += @venue.records.where(:calling_id => nil)
    @timeline = @timeline.sort{|x,y| y.created_at <=> x.created_at }
    @photos = @venue.photos.limit(7)
    @topics = @venue.topics.limit(7)
    @sayings = @venue.sayings.limit(7)
    @followers = @venue.followers.limit(8)
  end
  
  def edit
  end
  
  def update
    @venue.update_attributes(params[:venue]) if @venue.creator == current_user
    if params[:back_path].present?
      redirect_to params[:back_path]
    else
      respond_with(@venue)
    end
  end

  def cover
    render :layout => false if params[:layout] == 'false'
  end
  
  def position
    render :layout => false if params[:layout] == 'false'
  end
  
  def records
    if params[:tag].present?
      @records = @venue.records.find_tagged_with(params[:tag])
    elsif params[:marker] == 'true'
      @records = @venue.records.markers
    else
      @record = @venue.records
    end
    respond_with(@records)
  end
  
  def followers
    @followers = @venue.followers.paginate(:page => params[:page], :per_page => 20)
  end
  
  def more_items
    @items = eval({:followers => '@venue.followers[8..-1]',
                   :photos => "@venue.photos.paginate(:page => #{params[:page]}, :per_page => 6)",
                   :sayings => "@venue.sayings.paginate(:page => #{params[:page]}, :per_page => 6)",
                   }[params[:items].to_sym])
    render :layout => false
  end
  
  private
  def find_venue
    @venue = Venue.find(params[:id])
    
  end

end
