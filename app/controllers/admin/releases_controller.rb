class Admin::ReleasesController < AdminAreaController

  def index
    @releases = Release.all
  end

  def create
    @release = Release.new(self.safe_params())
    success  = @release.save

    redirect_to(action: 'index') if success
  end

  def edit
    @release = Release.find(params[:id])
    success  = @release.update(self.safe_params())

    redirect_to(action: 'index') if success
  end

  def destroy
    @release = Release.find_by_id(params[:id])
    @release&.destroy!

    redirect_to(action: 'index')
  end

  # ============================================================================
  # PRIVATE INSTANCE METHODS
  # ============================================================================
  #
  private

    def safe_params
      params.require(:release).permit([])
    end

end
