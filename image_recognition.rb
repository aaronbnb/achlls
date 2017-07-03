require_relative "page_scan"
require "google/cloud/vision"
require 'googleauth'
require "google/apis/storage_v1"

class ImageRecognition
  attr_accessor :labels, :file_name

  def initialize(img_src)
    # The name of the image file to annotate
    # @file_name = img_src
    @file_name = img_src
  end

  def self.get_scopes_and_authorization

    scopes = ['https://www.googleapis.com/auth/cloud-platform', 'https://www.googleapis.com/auth/devstorage.read_only']
    authorization = Google::Auth.get_application_default('/Users/aaronfarber/Desktop/achills/credentials.json')

    storage = Google::Apis::StorageV1::StorageService.new
    storage.authorization = authorization

  end

  def self.detect_text(img_src)

    # [START vision_text_detection]
    # project_id = "Your Google Cloud project ID"
    # image_path = "Path to local image file, eg. './image.png'"

    ImageRecognition.get_scopes_and_authorization

    # Your Google Cloud Platform project ID
    project_id = 'accessibility-167719'
    #project_id = '2e03176f6932eb9ce9318d5449e167d772f94a3a'
    # Instantiates a client
    vision = Google::Cloud::Vision.new project: project_id

    # The name of the image file to annotate
    file_name = img_src

    #performs text detection, I think??
    #need to find character limit
    text = vision.image(file_name).text

    puts text
  end

  def self.detect_text_gcs project_id:, image_path:

    #get_scopes_and_authorization

    vision = Google::Cloud::Vision.new project: project_id
    image = vision.image image_path

    puts image.text

  end

  def self.detect_labels
    #do I need this line? -- maybe call it in imageFix constructor
    #ImageRecognition.get_scopes_and_authorization

    # Your Google Cloud Platform project ID
    project_id = 'accessibility-167719'

    # Instantiates a client, create a Google::Cloud::Vision::Project
    vision = Google::Cloud::Vision.new project: project_id



    # Converts image file to a Cloud Vision image, enabling access to
    # full suite of Google Cloud methods
    @cloud_vision_image = vision.image(@file_name)

    # Performs label detection on the image file
    @labels = @cloud_vision_image.labels
    binding.pry
    activate_optical_character_recognition if ImageRecognition.text_in_image?

    "Labels:"
    @labels.each do |label|
      puts label.description
    end

  end

  def self.text_in_image?
    @labels.any? { |label| label.description == 'text' && label.score > 0.7 }
  end

  def text_in_image?
    @labels.any? { |label| label.description == 'text' && label.score > 0.7 }
  end

  def activate_optical_character_recognition
    #Use OCR on image
    image_text = @cloud_vision_image.text.text
    @parsed_text = eliminate_mid_sentence_newlines(image_text)
    puts @parsed_text
  end

  def eliminate_mid_sentence_newlines(image_text)
    image_text.gsub(/\n[a-z]/) { |old_text| " " + old_text[1] }
  end

end

if __FILE__ == $PROGRAM_NAME
  image_path = ARGV.shift
  project_id = ENV['accessibility-167719']

  if image_path
    ImageRecognition.detect_labels image_path: image_path, project_id: project_id
  else
    puts <<-usage
    Usage: ruby detect_text.rb [image file path]
    Example:
    ruby detect_text.rb image.png
    ruby detect_text.rb https://public-url/image.png
    ruby detect_text.rb gs://my-bucket/image.png
    usage
  end
end
