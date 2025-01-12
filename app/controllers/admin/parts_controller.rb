class Admin::PartsController < AdminAreaController

  def index
    @parts = Part.find(:all, :order => 'name ASC')
    @part = Part.new(params[:part])

    if request.post? && @part.save
      redirect_to :action => 'index'
    end
  end

  def edit
    @part = Part.find(params[:id])
    @part.attributes = params[:part]
    if request.post? && @part.save
      redirect_to :action => 'index'
    end
  end

  def delete
    #if request.post?
      part = Part.find(params[:id]) rescue nil
      redirect_to :action => 'index' unless part
      part.destroy
      redirect_to :action => 'index'
    #end
  end
end
