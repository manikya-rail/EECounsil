class SimpleNote < ApplicationRecord
  before_save :encrypt_note_content

  def decrypt_note_content
    crypt = ActiveSupport::MessageEncryptor.new(APP_CONFIG['CRYPT_KEY'])
    crypt.decrypt_and_verify(self.content)
  end

  private
    def encrypt_note_content
      crypt = ActiveSupport::MessageEncryptor.new(APP_CONFIG['CRYPT_KEY'])
      self.content = crypt.encrypt_and_sign(self.content)
    end
end
