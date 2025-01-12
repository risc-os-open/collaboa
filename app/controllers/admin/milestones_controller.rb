class Admin::MilestonesController < AdminAreaController

  def index
    @milestones = Milestone.find_all
    @milestone = Milestone.new(params[:milestone])

    if request.post? && @milestone.save
      redirect_to :action => 'index'
    end
  end
  
  def edit
    @milestone = Milestone.find(params[:id])
    @milestone.attributes = params[:milestone]
    if request.post? && @milestone.save
      redirect_to :action => 'index'
    end
  end
  
  def delete
    #if request.post?
      milestone = Milestone.find(params[:id]) rescue nil
      redirect_to :action => 'index' unless milestone      
      milestone.destroy
      redirect_to :action => 'index'
    #end
  end
end
