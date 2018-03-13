require './config/environment'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
    set :session_secret, "stratocaster"
  end

  get '/' do
    erb :index
  end

  get '/signup' do
    if is_logged_in?(session)
      redirect to '/tweets'
    else
      erb :signup
    end
  end

  post '/signup' do
    user = User.new(:username => params[:username], :password => params[:password], :email => params[:email])
    if user.save
      session[:user_id] = user.id
      redirect to '/tweets'
    else
      redirect to'/signup'
    end
  end

  get '/tweets' do
    if is_logged_in?(session)
      @user = current_user(session)
      @tweets = Tweet.all
      erb :tweets
    else
      redirect "/login"
    end
  end

  post '/tweets' do
    tweet = Tweet.create(:content => params[:content], :user_id => current_user(session).id)
    if tweet.save
      redirect '/tweets'
    else
      redirect '/tweets/new'
    end
  end

  get '/login' do
    if is_logged_in?(session)
      redirect "/tweets"
    else
      erb :login
    end
  end

  post '/login' do
    user = User.find_by(:username => params[:username])

    if user && user.authenticate(params[:password])
        session[:user_id] = user.id
        redirect "/tweets"
    else
        erb :login
    end
  end

  get '/logout' do
    if is_logged_in?(session)
      session.clear
      redirect "/login"
    else
      redirect "/"
    end
  end

  get '/users/:slug' do
    @user = User.find_by_slug(params[:slug])
    erb :user
  end

  get '/tweets/new' do
    if is_logged_in?(session)
      erb :new
    else
      redirect "/login"
    end
  end

  get '/tweets/:id' do
    if is_logged_in?(session)
      @tweet = Tweet.find(params[:id])
      erb :show
    else
      redirect "/login"
    end
  end

  get '/tweets/:id/edit' do
    if !is_logged_in?(session)
      redirect "/login"
    elsif Tweet.find_by id: params[:id]
      @tweet = Tweet.find(params[:id])
      erb :edit if current_user(session).id == @tweet.user_id
    else
      redirect "/tweets"
    end
  end

  patch '/tweets/:id' do
    @tweet = Tweet.find(params[:id])
    @tweet.content = params[:content]
    if @tweet.save
      redirect "/tweets"
    else
      redirect "/tweets/#{@tweet.id}/edit"
    end
  end

  delete '/tweets/:id/delete' do
    @tweet = Tweet.find(params[:id])
    if !is_logged_in?(session)
      redirect "/login"
    elsif current_user(session).id == @tweet.user_id
      @tweet.delete
    else
      redirect "/tweets"
    end
  end



  def current_user(session_hash)
    user = User.find_by(id: session_hash[:user_id])
    user
  end

  def is_logged_in?(session_hash)
    !!session_hash[:user_id]
  end

end
