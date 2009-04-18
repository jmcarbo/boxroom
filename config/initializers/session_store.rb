# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_testrails_session',
  :secret      => 'c1f7a85956dbb2d461f9f8c05b628efabe9166bb37c3b898631f9722711ffc1fb57fcf8e4a58a12e15d7db5e98ecc25be4a11a7498b006cbedf5d868d0326791'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
