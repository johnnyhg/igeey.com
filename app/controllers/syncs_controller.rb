class SyncsController < ApplicationController
  before_filter :login_required
  def new
    @sync = Sync.new(:syncable_id => params[:syncable_id],:syncable_type => params[:syncable_type].capitalize)
    if @sync.syncable.present? && @sync.syncable.user == current_user
      @syncable = @sync.syncable 
      render :layout => !(params[:layout] == 'false')
    else
      
    end
  end
  
  def create
    @sync = Sync.new(params[:sync])
    @sync.user = current_user
    @sync.save if @sync.syncable.user == current_user
    redirect_to eval("#{@sync.syncable_type.downcase}_url(#{@sync.syncable.id})")
  end
end
