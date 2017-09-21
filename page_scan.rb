require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'tinify'
require_relative 'image_recognition'
require_relative 'image_compression'

class PageScan
  attr_accessor :original_images, :repaired_image_text, :url
  attr_reader :violations, :image_rec_duration, :compression_duration,
              :detection_duration

  def initialize(url)
    start_timer

    @url = url

    ImageCompression.get_credentials
    ImageRecognition.get_scopes_and_authorization

    image_detection

    #compression

    image_recognition

    stop_timer

    display_duration_stats
  end


  def compression
    compression_start = Time.now
    compress_images
    compression_end = Time.now
    @compression_duration = compression_end - compression_start
  end

  def image_detection
    detection_start = Time.now
    @original_images = find_images
    @violations = detect_image_violations
    display_violations
    detection_end = Time.now
    @detection_duration = detection_end - detection_start
  end

  def image_recognition
    image_rec_start = Time.now
    #@repaired_image_text = process_compressed_images
    @repaired_image_text = process_images
    image_rec_end = Time.now
    @image_rec_duration = image_rec_end - image_rec_start
  end

  def detect_image_violations
    @original_images.count { |image| !image.attributes['alt'] }
  end

  def display_violations
    puts "\nWebpage has #{violations} violations of images
    without alternative text\n\n"
  end

  def display_duration_stats
    program_duration = @finish - @start
    average_image_time = program_duration / @original_images.count

    puts "Full page scan and image recogntion took #{program_duration}"

    puts "Average Time for each Image Recognition
    instance: #{average_image_time}"
  end

  def find_images
    webpage = Nokogiri::HTML open(@url)
    images = webpage.css('img')
    puts "\nWebpage has #{images.length} images\n"
    images
  end

  def repair_original_alt_text (image)

  end

  def compress_images
    # Image files sent to the Google Cloud Vision API should not exceed 4 MB
    # Preprocess such images to reduce them to a more reasonable image size,
    # while also downsampling them to a reasonable file size.

    @compressed_images = []

    @original_images.each do |image|
      img_src = get_img_src(image)
      puts img_src

      if img_src[-4..-1] =~ /jpeg|.png|jpg|JPEG/
        compressed_image = Tinify.from_url(img_src)
        @compressed_images.push(compressed_image.instance_variable_get(:@url))
      else
        @compressed_images.push(img_src)
      end
    end

  end

  def process_images
    i = 0
    @original_images.map do |image|
      img_src = get_img_src(image)
      puts "Image #{i += 1}"
      puts img_src
      ImageRecognition.new(img_src)
    end
  end

  def process_compressed_images
    i = 0
    @compressed_images.map do |compressed_img_src|
      puts "Image #{i += 1}"
      puts compressed_img_src
      # send image as base64 encoded image?
      # Maybe faster
      # ImageRecognition.new(compressed_image.to_buffer)

      # add all scanned images to set to avoid future API requests if
      # we've previously analzyed an image
      ImageRecognition.new(compressed_img_src)
    end
  end

  def start_timer
    @start = Time.now
  end

  def stop_timer
    @finish = Time.now
  end

  def get_img_src(image)
    image.attributes['src'].value.strip
    #check if valid url
  end

end
