require_relative "page_scan"
require "google/cloud/vision"
require 'googleauth'
require "google/apis/storage_v1"

class ImageRecognition
  attr_accessor :labels, :file_name, :vision, :alternative_text
  # Google Cloud Platform project ID
  PROJECT_ID ||= 'accessibility-167719'
  # Logical OR operation (lazy assignment) to remove 'already
  # initalized constant' warning

  def initialize(img_src)
    # The name of the image file to annotate
    # can provide HTTP/HTTPS URL or add as Google Cloud Storage URI
    @alternative_text = ""
    @file_name = img_src

    @vision = create_project

    @labels = broadly_categorize_image

    decision_depot

    puts @alternative_text
  end

  def self.get_scopes_and_authorization

    scopes = ['https://www.googleapis.com/auth/cloud-platform', 'https://www.googleapis.com/auth/devstorage.read_only']
    authorization = Google::Auth.get_application_default(scopes)

    storage = Google::Apis::StorageV1::StorageService.new
    storage.authorization = authorization

  end

  def self.detect_labels(img_src)
    #do I need this line? -- maybe call it in imageFix constructor
    #ImageRecognition.get_scopes_and_authorization

    # Your Google Cloud Platform project ID
    project_id = 'accessibility-167719'

    # Instantiates a client, create a Google::Cloud::Vision::Project
    vision = Google::Cloud::Vision.new project: PROJECT_ID

    @file_name = img_src

    # Converts image file to a Cloud Vision image, :enabling access to
    # full suite of Google Cloud methods
    @cloud_vision_image = vision.image(@file_name)

    # Performs label detection on the image file
    @labels = @cloud_vision_image.labels

    binding.pry

    "Labels:"
    @labels.each do |label|
      puts label.description
    end

  end

  def create_project
    # Instantiates a client, create a Google::Cloud::Vision::Project
    cloud_vision = Google::Cloud::Vision.new project: PROJECT_ID

    # Converts image file to Google Cloud Vision image, enabling access
    # to the full suite of Google Cloud methods
    cloud_vision.image(@file_name)
  end

  def broadly_categorize_image
    # Performs label detection on the image file, broadly categorizing
    # image properties for further, targeted recognition
    @vision.labels
  end

  def decision_depot
    activate_optical_character_recognition if text_in_image?

    @alternative_text += image_description
  end

  def text_in_image?
    @labels.any? { |label| label.description == 'text' && label.score > 0.7 }
  end

  def activate_optical_character_recognition
    #Use OCR on image
    image_text = @vision.text.text
    parsed_text = eliminate_mid_sentence_newlines(image_text)
    @alternative_text = alt_text_preface(parsed_text)
  end

  def eliminate_mid_sentence_newlines(image_text)
    image_text.gsub(/\n[a-z]/) { |old_text| " " + old_text[1] }
  end

  def alt_text_preface(text)
    "Image has text: " + text
  end

  def image_description
     "Labels include " + @labels.map(&:description).join(" ")
  end

end

if __FILE__ == $PROGRAM_NAME
  url = ARGV.last
  # project_id = ENV['accessibility-167719']

  if url
    PageScan.new(url)
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
