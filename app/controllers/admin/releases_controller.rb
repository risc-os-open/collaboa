class Admin::ReleasesController < AdminAreaController

  def index
  end
  
  def index
    @releases = Release.find :all
    @release = Release.new(params[:release])
    
    if request.post? && @release.save
      redirect_to :action => 'index'
    end  
  end
  
  def edit
    @release = Release.find(params[:id])
    @release.attributes = params[:release]
    if request.post? && @release.save
      redirect_to :action => 'index'
    end
  end
  
  def delete
    #if request.post?
      @release = Release.find(params[:id]) rescue nil
      redirect_to :action => 'index' unless @release
      @release.destroy
      redirect_to :action => 'index'
    #end
  end
end
