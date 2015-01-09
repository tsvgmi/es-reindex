class ESReindex
  class Railtie < Rails::Railtie
    initializer 'Rails ESReindex.logger' do
      ESReindex.logger = Rails.logger
    end
  end
end