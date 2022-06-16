class String
   def to_underscore!
     gsub!(" ", "_")
     gsub!(/(.)([A-Z])/,'\1_\2')
     downcase!
   end

   def to_underscore
     dup.tap { |s| s.to_underscore! }
   end

   def snakecase
     downcase.gsub(/[^a-z0-9]+/, '_')
   end
end
