# Include hook code here
require 'obfuscated'

ActiveRecord::Base.class_eval do
  include Obfuscated
end