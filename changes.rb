require 'bundler'
Bundler.require

require_relative 'mailer'

configure do
  require_relative 'site'
  DataMapper.finalize

  enable :sessions
end

configure :production do
  DataMapper::Logger.new($stdout, :info)
  set :session_secret, ENV['SESSION_SECRET']

  ActionMailer::Base.smtp_settings = {
    :address => "smtp.sendgrid.net",
    :port => '25',
    :authentication => :plain,
    :user_name => ENV['SENDGRID_USERNAME'],
    :password => ENV['SENDGRID_PASSWORD'],
    :domain => ENV['SENDGRID_DOMAIN'],
  }
end

configure :test do
  ENV['DATABASE_URL'] = 'postgres://localhost/changes_test'
  DataMapper::Logger.new($stdout, :error)
end

configure :development do
  ENV['DATABASE_URL'] = 'postgres://localhost/changes'
  DataMapper::Logger.new($stdout, :debug)
  set :session_secret, '1234567890abcdefg'

  ActionMailer::Base.smtp_settings = {
    :address => "localhost",
    :port => '1025'
  }
end

configure do
  DataMapper.setup(:default, ENV['DATABASE_URL'])
  DataMapper.auto_upgrade!
end

get '/' do
  haml :index
end

post '/sites' do
  @site = Site.new(params['site'])
  if @site.save
    flash[:message] = "Site added"
  else
    flash[:error] = @site.errors.to_a.flatten.join('. ')
  end
  redirect '/'
end
