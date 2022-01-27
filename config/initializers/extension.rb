
Dir["#{Rails.root}/lib/ruby_extensions/*.rb"].each { |file| require file }
Dir["#{Rails.root}/lib/rails_ext/*.rb"].each { |file| require file }