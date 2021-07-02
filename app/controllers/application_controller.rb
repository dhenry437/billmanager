class ApplicationController < ActionController::Base
  helper_method :current_user

  protected

  def after_sign_in_path_for(resource)
    '/'
  end

  def after_sign_out_path_for(resource)
    '/users/sign_in'
  end
end
