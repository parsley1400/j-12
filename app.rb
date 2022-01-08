require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?

require 'sinatra/activerecord'
require './models'

before do
    Dotenv.load
    Cloudinary.config do |config|
      config.cloud_name = ENV['CLOUD_NAME']
      config.api_key　  = ENV['CLOUDINARY_API_KEY']
      config.api_secret = ENV['CLOUDINARY_API_SECRET']
    end
    puts ENV['CLOUDINARY_API_KEY']
end

enable :sessions

helpers do
    def current_user
      User.find_by(id:session[:user])
    end
end


get '/' do
    if current_user.nil?
        @contributions = Contribution.none
    else
        @contributions = current_user.contributions
    end
    erb :index
end

get '/signup' do
   erb:sign_up 
end

post '/signup' do
    user = User.create(
        name: params[:name],
        password: params[:password],
        password_confirmation: params[:password_confirmation]
        )
    if user.persisted?
        session[:user] = user.id
    end
    redirect '/'
end

get '/signin' do
    erb :sign_in
end

post '/signin' do
    user = User.find_by(name: params[:name])
    if user && user.authenticate(params[:password])
        session[:user] = user.id
    end
    redirect '/'
end

get '/signout' do
    session[:user] = nil
    redirect '/'
end

get '/contributions/new' do
    @groupboxes = User_group.where(user_id: current_user.id)
    erb :new
end


post '/contributions' do
    img_url = ''
    if params[:file]
      img = params[:file]
      tempfile = img[:tempfile]
      upload = Cloudinary::Uploader.upload(tempfile.path)
      img_url = upload['url']
    end
     
    contribution = Contribution.create(
        text: params[:contribution_text],
        user_id: current_user.id
        )
    
    Image.create(
        image: img_url,
        contribution_id: contribution.id
        )  
    
    params[:group].each do |group|
      Contribution_group.create(group_id: group, contribution_id: contribution.id)
    end
    
    redirect '/'
end

get '/creategroup' do
    erb :create_group
end

post '/creategroup' do
 group= Group.create(
        name: params[:group_name],
        password: params[:group_password],
        password_confirmation: params[:group_password_confirmation]
        )
User_group.create(
        user_id: current_user.id,
        group_id: group.id
    )
    redirect "/group/#{group.id}"
end

get '/group/:id' do
    @group = params[:id]
    @grouppages = Contribution_group.where(group_id: @group)
    erb :group_page
end

get '/grouplist' do
    if current_user.nil?
        @groupids = User_group.none
    else
        @groupids = User_group.where(user_id: current_user.id)
    end
    erb :group_list
end

get '/joingroup' do
    erb :join_group
end

post '/joingroup' do
    group = Group.find_by(name: params[:name])
    if group && group.authenticate(params[:password])
        User_group.create(
        user_id: current_user.id,
        group_id: group.id
    )
    end
    redirect '/'
end

