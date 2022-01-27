class PayerCreationWorker
  include Sidekiq::Worker

  def perform
    values = [["ABHFL", "Aetna Better Health of Florida"], ["ABHKY", "Aetna Better Health of Kentucky"], ["ABHLA", "Aetna Better Health of Louisiana
    "], ["ABHMO", "Aetna Better Health of Missouri"], ["AETNX", "AETNA"], ["BCCTC", "Blue Cross Blue Shield Connecticut
    "], ["BCNJC", "BCBS of New Jersey (Horizon)"], ["CIGNA", "CIGNA for dependent"], ["CNTCR", "Connecticare Inc.
    "], ["COVON", "Coventry"], ["CT", "Connecticut Medicaid"], ["HUM", "Humana"], ["ILMSA", "Aetna Better Health of Illinois"], ["ISCAM", "Medi-CAL Portal connection
    "], ["MEDX", "MEDEX"], ["MMSI", "Mayo"], ["TRICE", "Tricare"], ["TX", "Texas Medicaid"], ["UHC", "United Healthcare
    "]]
    values.each do |value|
      Payer.find_or_create_by!(payer_id: value[0], payer_name: value[1])
    end
  end
end
