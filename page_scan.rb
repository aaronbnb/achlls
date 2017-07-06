require 'rubygems'
require 'nokogiri'
require 'open-uri'
require_relative 'image_recognition'

require "tinify"
Tinify.key = "Gyu3sNUGM1GOw513yneGDEd2ApvW39hd"

class PageScan
  attr_accessor :original_images, :repaired_images

  def initialize(url)
    ImageRecognition.get_scopes_and_authorization

    @original_images = find_images(url)
    @violations = detect_image_violations
    display_violations
    @repaired_images = process_images
  end

  def detect_image_violations
    @original_images.count { |image| !image.attributes['alt'] }
  end

  def display_violations
    puts "\nWebpage has #{violations} violations of images
    without alternative text\n\n"
  end

  def find_images(url)
    webpage = Nokogiri::HTML open(url)
    images = webpage.css('img')
    puts "\nWebpage has #{images.length} images\n"
    images
  end

  def compress_images

    Tinify.from_url("https://cdn.tinypng.com/images/panda-happy.png")
    # Image files sent to the Google Cloud Vision API should not exceed 4 MB
    # Batch the images
    # Preprocess such images to reduce them to a more reasonable image size,
    # while also downsampling them to a reasonable file size.
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
