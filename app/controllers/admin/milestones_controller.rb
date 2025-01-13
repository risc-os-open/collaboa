class Admin::MilestonesController < AdminAreaController
  def index
    @milestones = Milestone.all
    @milestone  = Milestone.new
  end

  def create
    @milestone = Milestone.new(self.safe_params())
    success    = @milestone.save()

    redirect_to(action: 'index') if success
  end

  def edit
    @milestone = Milestone.find(params[:id])
  end

  def update
    @milestone  = Milestone.find(params[:id])
    success     = @milestone.update(self.safe_params())

    redirect_to(action: 'index') if success
  end

  def destroy
    milestone = Milestone.find_by_id(params[:id])
    milestone&.destroy!

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
