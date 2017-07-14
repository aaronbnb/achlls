require_relative "page_scan"
require "google/cloud/vision"
require 'googleauth'
require "google/apis/storage_v1"

class ImageRecognition
  attr_accessor :labels, :file_name, :vision, :alternative_text
  # Google Cloud Platform project ID
  PROJECT_ID ||= 'accessibility-167719'.freeze

  def initialize(img_src)
    # The name of the image file to annotate
    # can provide HTTP/HTTPS URL or add as Google Cloud Storage URI
    # Compress image (if image needs to be compressed) at this point
    start = Time.now
    @alternative_text = ""
    @file_name = img_src

    @vision = create_project

    @labels = broadly_categorize_image

    decision_depot
    finish = Time.now
    @duration = finish - start
  end

  def self.get_scopes_and_authorization

    scopes = ['https://www.googleapis.com/auth/cloud-platform', 'https://www.googleapis.com/auth/devstorage.read_only']
    authorization = Google::Auth.get_application_default(scopes)

    storage = Google::Apis::StorageV1::StorageService.new
    storage.authorization = authorization

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
    count = 0
    labels = {}
    @vision.labels.each do |label|
      labels[label.description] = label.score
    end
    labels
  end

  def decision_depot
    activate_optical_character_recognition if text_in_image?

    @alternative_text += image_description
  end

  def text_in_image?
    # Provides alt text for image
    # Tests whether there is text in hash, whether has (confidence) score
    # greater than 0.70, and makes sure it's not a false positive i.e.
    # an 'X' logo to close window
    @labels['text'] && @labels['text'] > 0.7 && @vision.text
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
    "Labels include " + @labels.keys.join(' ')
  end

end

if __FILE__ == $PROGRAM_NAME
  url = ARGV.last
  # project_id = ENV['accessibility-167719']

  if url
    PageScan.new(url)
  else
    puts <<-usage
    Usage:
    PageScan.new(url string)
    or load 'image_recognition.rb' then img_src
    usage
  end
end
