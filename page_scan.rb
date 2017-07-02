require 'rubygems'
require 'nokogiri'
require 'open-uri'
require_relative 'image_recognition.rb'

class PageScan
  attr_reader :images

  def initialize(url)
    ImageRecognition.get_scopes_and_authorization

    @images = find_images(url)
    detect_image_violations
    generate_alternative_text
    @repaired_images
  end

  def detect_image_violations
    violations = 0
    @images.each do |image|
      violations += 1 unless image.attributes.to_s.include?('alt')
      #violations += 1 unless image.attributes.key?('alt')
      binding.pry
    end
    puts "\nWebpage has #{violations} violations of images without alternative text\n\n"
  end

  def print_raw_images
    puts "\n"
    puts @images
    puts "\n"
  end

  def find_images(url)
    webpage = Nokogiri::HTML.open(url)
    images = webpage.css('img')
    puts "\nWebpage has #{images.length} images\n"
    images
  end

  def generate_alternative_text
    @images.each_with_index do |image, i|
      img_src = get_img_src(image)
      puts "Image #{i}"
      puts img_src
      ImageRecognition.detect_labels(img_src)
    end
  end

  def get_img_src(image)
    image.attributes['src'].value
  end

end
