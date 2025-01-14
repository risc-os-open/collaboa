class RepositoryController < ApplicationController
  before_action :redirect_if_unsupported, except: [:changesets, :show_changeset]
  before_action :login_required

  def browse
    path = params[:path].to_s
    @rev = params[:rev]
    if Repository.is_dir?(path)
      @current_entry = Repository.get_node_entry(path, @rev)
      @node_entries = @current_entry.entries#Repository.get_node_entries(path, @rev)
      @node_entries.sort!{ |x,y| x.name.downcase <=> y.name.downcase }
      @node_entries.sort!{ |x,y| x.type <=> y.type }
      GC.start
    else
      redirect_to :action => 'view_file', :path => params[:path]
    end
  end

  # TODO: check so that filesize is reasonable, before doing anything
  def view_file
    path = params[:path].to_s
    @rev = params[:rev]
    if Repository.is_dir?(path)
      redirect_to :action => 'browse', :path => params[:path]
    else
      @file = Repository.get_node_entry(path, @rev)
      if params[:format] == 'raw'
        send_data(@file.contents, filename: path)
      elsif @params[:format] == 'txt'
        send_data(@file.contents, type: "text/plain", disposition: 'inline')
      else
        if @file.is_textual?
          render :action => 'showfile'
        elsif @file.is_image?
          render :action => 'showimage'
        else
          render :action => 'showunknown'
        end
      end
    end
  end

  def changesets
    @changeset_pages, @changesets = pagy_with_params(
      scope:         Changeset.all,
      default_limit: 15
    )
  end

  def show_changeset
    @changeset = Changeset.find_by_revision(params[:revision])

    if @changeset.nil?
      redirect_to :action => 'changesets'
    else
      if SVN_ENABLED
        @files_to_diff = @changeset.code_changes.reject {|change|  change.name != 'M' }
        @files_to_diff.reject! {|f| !f.diffable? }
      else
        @files_to_diff = []
      end
    end
  end

  def revisions
    path = params[:path].to_s
    Rails.logger.debug "** PATH: #{path}"
    redirect_to :action => 'browse' if path.empty?
    @changes = Change.find_all_by_path(path, :order => 'created_at DESC', :include => :changeset)
  end

  def send_data_to_browser
    path = params['path'].to_s
    @rev = params[:rev]
    file = Repository.get_node_entry(path, @rev)

    send_data(file.contents, type: file.mime_type, disposition: 'inline')
  end

  # ============================================================================
  # PRIVATE INSTANCE METHODS
  # ============================================================================
  #
  private

    # Ruby bindings and related files in 2024 are a challenge, to say the least.
    #
    def redirect_if_unsupported
      unless SVN_ENABLED
        flash[:attention] = 'Subversion browsing is no longer supported - all code is maintained on the ROOL GitLab server.'
        redirect_back_or_to(root_path())
      end
    end

    def authorize?(user)
      if %w{changesets show_changeset}.include?(action_name)
        user.view_changesets?
      else
        user.view_code?
      end
    end

end
