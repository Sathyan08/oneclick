class ApplicationController < ActionController::Base
  include CsHelpers

  protect_from_forgery
  before_filter :set_locale
  after_filter :clear_location

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => exception.message
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options(options={})
    { :locale => ((I18n.locale == I18n.default_locale) ? nil : I18n.locale) }
  end

  def clear_location
    session.delete :location
  end

end
