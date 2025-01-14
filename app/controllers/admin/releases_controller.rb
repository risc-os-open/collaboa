class Admin::ReleasesController < AdminAreaController

  # This doubles up as an inline 'new' action, for convenience.
  #
  def index
    @releases = Release.order('created_at DESC')
  end

  # Handles submissions from the inline index view form.
  #
  def create
    self.index() # Initialise ivars

    @release = Release.new(self.safe_params())
    success  = @release.save
    success ? redirect_to(action: 'index') : render(action: 'index')
  end

  def edit
    @release = Release.find(params[:id])
    success  = @release.update(self.safe_params())
    success ? redirect_to(action: 'index') : render(action: 'edit')
  end

  def destroy
    release = Release.find(params[:id])
    release.destroy!

    flash[:notice] = "Release '#{release.name}' deleted"

    redirect_to(action: 'index')
  end

  # ============================================================================
  # PRIVATE INSTANCE METHODS
  # ============================================================================
  #
  private

    def safe_params
      params.require(:release).permit(:name)
    end

end
