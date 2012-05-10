require 'digest/sha1'
require 'active_record'

module Obfuscated
  mattr_accessor :salt

  def self.append_features(base)
    super
    base.extend(ClassMethods)
  end
  
  def self.supported?
    @@mysql_support ||= ActiveRecord::Base.connection.class.to_s.downcase.include?('mysql') ? true : false
  end
  
  module ClassMethods
    def has_obfuscated_id( options={} )
      class_eval do

        include Obfuscated::InstanceMethods

        # Uses an 12 character string to find the appropriate record
        def self.find_by_hashed_id( hash, options={} )
          # Don't bother if there's no hash provided.
          return nil if hash.blank?
          
          # If Obfuscated isn't supported, use ActiveRecord's default finder
          return find_by_id(hash, options) unless Obfuscated::supported?
          
          # Update the conditions to use the hash calculation
          options.update(:conditions => ["SUBSTRING(SHA1(CONCAT('---',#{self.table_name}.id,'-WICKED-#{self.table_name}-#{Obfuscated::salt}')),1,12) = ?", hash])
          
          # Find it!
          first(options) or raise ActiveRecord::RecordNotFound, "Couldn't find #{self.class.to_s} with Hashed ID=#{hash}"
        end

      end
    end

    def find( primary_key )
      if primary_key.is_a?(String) && primary_key.length == 12
        find_by_hashed_id( primary_key )
      else
        super
      end
    end
    
  end
  
  module InstanceMethods
    # Generate an obfuscated 12 character id incorporating the primary key and the table name.
    def hashed_id
      raise 'This record does not have a primary key yet!' if id.blank?
      
      # If Obfuscated isn't supported, just return the normal id
      return id unless Obfuscated::supported?
      
      # Use SHA1 to generate a consistent hash based on the id and the table name
      @hashed_id ||= Digest::SHA1.hexdigest(
        "---#{id}-WICKED-#{self.class.table_name}-#{Obfuscated::salt}"
      )[0..11]  
    end

    def to_param
      hashed_id
    end

  end
  
end

ActiveRecord::Base.class_eval do
  include Obfuscated
end