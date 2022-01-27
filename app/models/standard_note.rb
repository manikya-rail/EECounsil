class StandardNote < ApplicationRecord
  # has_and_belongs_to_many :risk_factors
  # has_and_belongs_to_many :interventions
  before_save :encrypt_note_summary

  def decrypt_note_summary
    crypt = ActiveSupport::MessageEncryptor.new(APP_CONFIG['CRYPT_KEY'])
    crypt.decrypt_and_verify(self.summary)
  end

  private
    def encrypt_note_summary
      crypt = ActiveSupport::MessageEncryptor.new(APP_CONFIG['CRYPT_KEY'])
      self.summary = crypt.encrypt_and_sign(self.summary)
    end
end
