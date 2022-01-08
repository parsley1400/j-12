require 'bundler/setup'
Bundler.require

ActiveRecord::Base.establish_connection

class User < ActiveRecord::Base
    has_many :contributions
    has_many :user_groups
    has_many :groups, through: :user_groups
    has_secure_password
    validates :name,
     presence: true,
     format: { with: /\A\w+\z/ }
    validates :password,
     length: { in: 5..10 },
     confirmation: true
end

class User_group < ActiveRecord::Base
    belongs_to :user
    belongs_to :group
end

class Group < ActiveRecord::Base
    has_many :user_groups
    has_many :users, through: :user_groups
    has_many :contribution_groups
    has_many :contributions, through: :contribution_groups
    has_secure_password
end

class Contribution_group < ActiveRecord::Base
    belongs_to :group
    belongs_to :contribution
end

class Contribution < ActiveRecord::Base
    belongs_to :user
    has_many :images
    has_many :contribution_groups
    has_many :groups, through: :contribution_groups
end

class Image < ActiveRecord::Base
    belongs_to :contribution
end