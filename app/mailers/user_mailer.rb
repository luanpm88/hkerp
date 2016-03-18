class UserMailer < ActionMailer::Base
  default from: "admin@hoangkhang.com.vn"
  
  def test_first_email(user)
    @user = user
    
    mail(to: user.email, subject: 'Sample Email')
  end
  
  def send_notification(notification)
    @notification = notification
    @user = notification.user
    
    mail(to: @user.email, subject: notification.display_title)
  end
end
