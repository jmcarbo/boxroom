# The search controller contains the following actions:
# [#show_results] performs a full-text search using Ferret
class SearchController < ApplicationController
  # Performs a full-text search using Ferret.
  # Only the files that can be read are returned.
  def show_results
    if request.post?
      @search_query = params[:search][:query]
      @result = [] # array to hold the results

      # Search with Ferret in both Folder (name)
      # and Myfile (filename and text)
      Folder.multi_search(@search_query, [Myfile]).each do |hit|
        if hit.class == Folder
          @result << hit if @logged_in_user.can_read(hit.id)
        elsif hit.class == Myfile
          @result << hit if @logged_in_user.can_read(hit.folder.id)
        end
      end
    end
  end
end