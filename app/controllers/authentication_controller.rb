# This authentication controller has a number of functions
# [#login]           Show the login view and login users
# [#create_admin]    Create the first user: admin
# [#forgot_password] Generate and mail a new password
# [#logout]          Logs out the current user (clears session)
class AuthenticationController < ApplicationController
  skip_before_filter :authorize

  # Display the login form and wait for user to enter a name and password.
  # We then validate these, adding the user object to the session if they authorize.
  def login
    if request.get?
      session[:user_id] = nil
    else
      # Try to get the user with the supplied username and password
      logged_in_user = User.login(params[:user][:name], params[:login][:password])

      # Create the session and redirect
      unless logged_in_user.blank?
        session[:user_id] = logged_in_user.id
        jumpto = session[:jumpto] || { :action => 'list', :controller => 'folder' }
        session[:jumpto] = nil
        redirect_to(jumpto)
      else
        flash.now[:login_error] = 'Invalid username/password combination'
      end
    end
  end

  # Show a form for creating the first user.
  # Creates the first user: admin.
  # Create the first group: admins.
  # Add the admin to the admins group.
  # Create the Root folder
  # Give the admins group CRUD rights to the Root folder.
  # The newly created admin user will be logged in automatically.
  # Initialize the Ferret index.
  def create_admin
    # Check if there already is an admin
    redirect_to(:action => 'login') and return false if User.admin_exists?

    if request.post?
      # Create the object for the administrator user
      @user = User.create_admin(params[:user][:email], params[:user][:name], params[:user][:password], params[:user][:password_confirmation])

      # Create Admins group, Root folder and the permissions 
      if @user.save
        Group.create_admins_group
        Folder.create_root_folder
        GroupPermission.create_initial_permissions
        session[:user_id] = @user.id # Login
        redirect_to(:action => 'list', :controller => 'folder')
      end

      # Create the initial Ferret index for files
      # (note: The index for Folders was created when we created the Root folder)
      Myfile.rebuild_index
    end
  end

  # Generate/mail a new password for/to users who have forgotten it.
  def forgot_password
    if request.post?
      # Try to generate and mail a new password
      result = User.generate_and_mail_new_password(params[:user][:name], params[:user][:email])

      # Act according to the result
      if result['flash'] == 'forgotten_notice'
        flash.now[:forgotten_notice] = result['message']
      else
        flash[:login_confirmation] = result['message']
        redirect_to(:action => 'login')
      end
    end
  end

  # Clear the current session and redirect to the login form.
  def logout
    reset_session
    @logged_in_user = nil
    redirect_to :action => 'login'
  end
end