class Admin::MilestonesController < AdminAreaController

  # This doubles up as an inline 'new' action, for convenience.
  #
  def index
    @milestones = Milestone.order('created_at DESC')
  end

  # Handles submissions from the inline index view form.
  #
  def create
    self.index() # Initialise ivars

    @milestone = Milestone.new(self.safe_params())
    success    = @milestone.save()
    success ? redirect_to(action: 'index') : render(action: 'index')
  end

  def edit
    @milestone = Milestone.find(params[:id])
  end

  def update
    @milestone  = Milestone.find(params[:id])
    success     = @milestone.update(self.safe_params())
    success ? redirect_to(action: 'index') : render(action: 'edit')
  end

  def destroy
    milestone = Milestone.find(params[:id])
    milestone.destroy!

    flash[:notice] = "Milestone '#{milestone.name}' deleted"

    redirect_to(action: 'index')
  end

  # ============================================================================
  # PRIVATE INSTANCE METHODS
  # ============================================================================
  #
  private

    def safe_params
      params.require(:milestone).permit(
        :name,
        :info,
        :due,
        :completed
      )
    end

end
