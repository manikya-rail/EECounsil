namespace :populate_payer_table do
  desc "Populate payer table"
  task populate_payer_table: :environment do
    PayerCreationWorker.perform_async
  end
end