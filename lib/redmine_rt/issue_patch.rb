module RedmineRt
  # Patches Redmine's Issues. 
  module IssuePatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      # Same as typing in the class
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development

        after_save :notify_save
        after_destroy :notify_destroy
      end
    end
  end

  module ClassMethods
  end

  module InstanceMethods
    def notify_save
      ActionCable.server.broadcast 'messages',
        { event: 'saved'}
    end
    def notify_destroy
      ActionCable.server.broadcast 'messages',
        { event: 'destroyed'}
    end
  end
end    
