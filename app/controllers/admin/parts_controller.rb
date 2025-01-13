class Admin::PartsController < AdminAreaController
  def index
    @parts = Part.all.order('name ASC')
    @part  = Part.new
  end

  def create
    @part   = Part.new(self.safe_params())
    success = @part.save()

    redirect_to(action: 'index') if success
  end

  def edit
    @part = Part.find(params[:id])
  end

  def update
    @part   = Part.find(params[:id])
    success = @part.update(self.safe_params())

    redirect_to(action: 'index') if success
  end

  def destroy
    part = Part.find_by_id(params[:id])
    part&.destroy!

    redirect_to(action: 'index')
  end

  # ============================================================================
  # PRIVATE INSTANCE METHODS
  # ============================================================================
  #
  private

    def safe_params
      params.require(:part).permit([])
    end

end
