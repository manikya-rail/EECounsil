#rake populate_data:populate_procedure_codes
namespace :populate_data do
  desc "Populate Procedure Codes table"
  task populate_procedure_codes: :environment do
    sample_data = [{"code":"90834", "description":"Psychotherapy, 45 min", "duration":"50"},
                  {"code":"+90838", "description":"Psychotherapy Add-on, 60 min", "duration":"50"},
                  {"code":"90791", "description":"Psychiatric Diagnostic Evaluation", "duration":"50"},
                  {"code":"90837", "description":"Psychotherapy, 60 min", "duration":"50"},
                  {"code":"90847", "description":"Family psychotherapy, conjoint psychotherapy with the patient present", "duration":"50"},
                  {"code":"90853","description":"Group Therapy", "duration":"50"},
                  {"code":"90875", "description":"Other Psychiatric Services or Procedures", "duration":"50"}]
    sample_data.each do |ele|
      proc_code = ProcedureCode.find_or_create_by(code: ele[:code])
      proc_code.update!(description: ele[:description], duration: ele[:duration])
    end
  end

  #rake populate_data:populate_diagnosis_codes[diagnosis.csv]
  desc "Populate Diagnosis Codes table"
  task :populate_diagnosis_codes, [:file_name] => :environment do |t, args|
    require 'csv'
    puts 'CSV loading....'
    CSV.foreach(args[:file_name], headers: true) do |ele|
      DiagnosisCode.create!(code: ele['ICD-10 DiagnosisCode'], description: ele['ICD-10 Diagnosis Description'])
    end
  end

  #rake populate_data:populate_place_of_service_codes[placeofservicecode.csv]
  desc "Populate Place of Service Codes table"
  task :populate_place_of_service_codes, [:file_name] =>  :environment do |t, args|
    require 'csv'
    puts 'CSV loading....'
    CSV.foreach(args[:file_name], headers: true) do |ele|
      PlaceOfServiceCode.create!(code: ele['Place of Service Code(s)'], name: ele['Place of Service Name'])
    end
  end


  desc "Change feature orders"
  task change_plan_features: :environment do
    ActiveRecord::Base.connection.execute('TRUNCATE features RESTART IDENTITY')
    features_ary = ['Custom White Label Homepage', 'Zoom Video', 'Credit Card Processing',
                    'Electronic Notes', 'Automated Scheduling', 'Automated Billing', 'Client Messaging',
                    'Document Sharing', 'Invite Clients', 'Unlimited Insurance Claims Processing',
                    'Dedicated Business Phone Line', 'Online Faxing System']
    features_ary.each do |feature|
      Feature.create(feature_name: feature)
    end
  end
end
