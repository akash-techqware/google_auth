class SessionsController < ApplicationController
  def new
    if logged_in?
      redirect_to root_path
    end
  end

  def create
    # binding.pry
    user = User.find_by(username: params[:username])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_path
    else
      render :new
    end
  end

  def destroy  # logout user session
    session.delete :user_id
    redirect_to login_path
  end

  def omniauth
    # binding.pry
    # byebug
    user = User.find_or_create_by(uid: request.env['omniauth.auth'][:uid], provider: request.env['omniauth.auth'][:provider]) do |u|
      u.username =  request.env['omniauth.auth'][:info][:first_name]
      u.email = request.env['omniauth.auth'][:info][:email]
      u.password = SecureRandom.hex(20)
    end
    if user.valid?
      session[:user_id] = user.id   #log them in
      redirect_to root_path  # redirect somewhere
    else
      redirect_to login_path
    end
  end
end
