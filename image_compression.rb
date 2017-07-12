require "tinify"

class ImageCompression
  # TinyPNG API Key
  COMPRESSION_KEY ||= "Gyu3sNUGM1GOw513yneGDEd2ApvW39hd".freeze
  # Logical OR operation (lazy assignment) to remove 'already
  # initalized constant' warning
  def self.get_credentials
    Tinify.key = COMPRESSION_KEY
  end
end
