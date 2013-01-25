class User < ActiveRecord::Base
#	belongs_to :batch
#	belongs_to :rollout
#	has_many :rollouts, :through => :batch
#	has_many :updates
#
#	validates_uniqueness_of :anid
#	validates_presence_of :role, :batch, :version
#
#	# Roles
#	ADMIN = 1.freeze
#	USER  = 2.freeze
#	FAKE  = 9.freeze
#
#	# Versions
#	V1 = 1
#
#	def version_text
#		case self.version
#			when 0x03 then V1
#			else raise ArgumentException.new('Invalid version code')
#		end
#	end
end
