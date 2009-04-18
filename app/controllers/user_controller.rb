# The user controller contains the following actions:
# [#index]   the default action, redirects to list
# [#list]    list all the users
# [#new]     shows the form for creating a new user
# [#create]  create a new user
# [#edit]    show the form for adjusting the attributes of a user
# [#update]  updates the attributes of a user
# [#destroy] delete a user
class UserController < ApplicationController
  before_filter :authorize_admin, :except => [:edit, :update]
  before_filter :does_user_exist, :only => [:edit, :update, :destroy]
  before_filter :do_not_destroy_admin_user, :only => :destroy

  # The default action, redirects to list.
  def index
    list
    render :action => 'list'
  end

  # List all the users.
  def list
    @users = User.find(:all, :order => 'name')
  end

  # Show a form to enter data for a new user.
  def new
    @user = User.new
  end

  # Create a new user using the posted data from the 'new' view.
  def create
    if request.post?
      @user = User.new(params[:user])
      @user.password_required = true

      # add the user to the selected groups
      add_user_to_groups(@user, params[:belongs_to_group])

      if @user.save
        begin
          # send an e-mail to the new user; informing him about his account
          PasswordMailer.deliver_new_user(@user.name, @user.email, params[:user][:password])
          flash[:user_confirmation] = "The new user's account information has been e-mailed to " + @user.email
          redirect_to :action => 'list'
        rescue Exception => e
          if e.message.match('getaddrinfo: No address associated with nodename')
            flash[:user_error] = 'The mail server settings in the environment file are incorrect. Check the installation instructions to solve this problem. The user was created nevertheless.'
          else
            flash[:user_error] = e.message + ".<br /><br />This means either the user's e-mail address or Boxroom's configuration for e-mailing is invalid. Please contact the administrator or check the installation instructions. The user was created nevertheless."
          end
          redirect_to :action => 'list'
        end
      else
        render :action => 'new'
      end
    end
  end

  # Show a form in which the data of a user can be edited.
  def edit
    render
  end

  # Update the user attributes with the posted variables from the 'edit' view.
  def update
    if request.post?
      # add the user to the selected groups
      add_user_to_groups(@user, params[:belongs_to_group])

      if @user.update_attributes(params[:user])
        # If a user edited his/her own settings: show a confirmation in the edit screen
        # else: redirect to the list of users
        if @user == @logged_in_user
          flash[:user_confirmation] = 'You saved your settings successfully'
          redirect_to :action => 'edit', :id => params[:id]
        else
          redirect_to :action => 'list'
        end
      else
        render :action => 'edit'
      end
    end
  end

  # Delete a user.
  def destroy
    @user.destroy
    redirect_to :action => 'list'
  end

  # These methods are private:
  # [#add_user_to_groups]        Add the user to the groups that are checked in the view
  # [#do_not_destroy_admin_user] Via before_filter: make sure admin is not deleted
  # [#does_user_exist]           Check if a user exists
  private
    # Add the user to the groups that are checked in the view
    def add_user_to_groups(user, group_check_box_list)
      if group_check_box_list and @logged_in_user.is_admin?
        user.groups.clear # remove the user from all groups

        # admins is not in the list cause it's disabled;
        # add it hardcodedly (is that a word?!?) in case of
        # <i>the administrator</i>
        user.groups.push(Group.find_by_is_the_administrators_group(true)) if user.is_the_administrator?

        # iteratively add the user to the selected groups
        group_check_box_list.each do |group_id, belongs_to|
          if belongs_to == 'yes'
            group = Group.find_by_id(group_id)
            user.groups.push(group) if group # add user to the selected group
          end
        end
      end
    end

    # The admin user can not be deleted.
    # By calling this method via a before_filter,
    # you makes sure this doesn't happen.
    def do_not_destroy_admin_user
      if @user and @user.is_the_administrator?
        redirect_to :action => 'list' and return false
      end
    end

    # Check if a user exists before executing an action.
    # If it doesn't exist: redirect to 'list' and show an error message
    def does_user_exist
      # only admins can edit other users's data
      if @logged_in_user.is_admin?
        @user = User.find(params[:id])
      else
        @user = @logged_in_user
      end
    rescue
      flash.now[:user_error] = 'Someone else deleted the user. Your action was cancelled.'
      redirect_to :action => 'list' and return false
    end
end