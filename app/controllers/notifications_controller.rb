class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications.unread
    @read_notifications = current_user.notifications.read
  end

  def show
    notification = current_user.notifications.find(params[:id])
    notification.mark_as_read!

    if (url = notification.to_notification.url)
      redirect_to url
    else
      redirect_to notifications_path, notice: t(".notice")
    end
  end
end
