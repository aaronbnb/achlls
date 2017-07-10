require 'rubygems'
require 'nokogiri'
require 'open-uri'
require_relative 'image_recognition'

require "tinify"
Tinify.key = "Gyu3sNUGM1GOw513yneGDEd2ApvW39hd"

class PageScan
  attr_accessor :original_images, :repaired_images, :url
  attr_reader :violations

  def initialize(url)
    start_timer

    ImageRecognition.get_scopes_and_authorization
    @url = url
    @original_images = find_images
    @violations = detect_image_violations
    display_violations
    @repaired_images = process_images

    stop_timer
    display_duration_stats
  end

  def start_timer
    @start = Time.now
  end

  def stop_timer
    @finish = Time.now
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

  def compress_image(img_src)
    # Image files sent to the Google Cloud Vision API should not exceed 4 MB
    # Preprocess such images to reduce them to a more reasonable image size,
    # while also downsampling them to a reasonable file size.

    compressed_img = Tinify.from_url(img_src)
    compressed_img.to_file
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

  def get_img_src(image)
    image.attributes['src'].value.strip
    #check if valid url
  end

end
