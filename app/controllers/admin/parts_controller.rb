class Admin::PartsController < AdminAreaController

  # This doubles up as an inline 'new' action, for convenience.
  #
  def index
    @parts = Part.order('name ASC')
    @part  = Part.new
  end

  # Handles submissions from the inline index view form.
  #
  def create
    self.index() # Initialise ivars

    @part   = Part.new(self.safe_params())
    success = @part.save()
    success ? redirect_to(action: 'index') : render(action: 'index')
  end

  def edit
    @part = Part.find(params[:id])
  end

  def update
    @part   = Part.find(params[:id])
    success = @part.update(self.safe_params())
    success ? redirect_to(action: 'index') : render(action: 'edit')
  end

  def destroy
    part = Part.find(params[:id])
    part.destroy!

    flash[:notice] = "Part '#{part.name}' deleted"

    redirect_to(action: 'index')
  end

  # ============================================================================
  # PRIVATE INSTANCE METHODS
  # ============================================================================
  #
  private

    def safe_params
      params.require(:part).permit(:name)
    end

end
