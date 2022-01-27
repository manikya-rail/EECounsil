class CreateFeatures < ActiveRecord::Migration[5.2]
  def change
    create_table :features do |t|
      t.string :feature_name
      t.timestamps
    end


    features_ary = ['Custom Homepage', 'HIPAA Compliant Video Conferencing', 'Invite Clients',
                    'Document Sharing','Credit Card Processing', 'Manual Charge', 'Automated Scheduling',
                    'Automated Billing', 'Client Messaging', 'Electronic Client Notes',
                    'Dedicated Business Phone Line', 'Online Faxing System']
    features_ary.each do |feature|
      Feature.create(feature_name: feature)
    end
  end
end
