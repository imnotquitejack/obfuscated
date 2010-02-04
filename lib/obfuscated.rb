require 'digest/sha1'
require 'active_record'

module Obfuscated
  @@mysql_support = ActiveRecord::Base.connection.class.to_s.downcase.include?('mysql') ? true : false
  
  def self.append_features(base)
    super
    base.extend(ClassMethods)
  end
  
  def self.supported?
    @@mysql_support
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
          
          #Update the options to use the hash calculation
          options.update(:conditions => ["SUBSTRING(SHA1(CONCAT('---',#{self.table_name}.id,'-WICKED-#{self.table_name}-')),1,12) = ?", hash])
          
          # Find it!
          first(options)
        end

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
      Digest::SHA1.hexdigest("---#{id}-WICKED-#{self.class.table_name}-")[0..11]  
    end
  end
  
end
