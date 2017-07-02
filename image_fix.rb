require 'rubygems'
require 'nokogiri'
require 'open-uri'
require_relative 'image_recognition.rb'

class ImageFix
  attr_reader :images

  def initialize(url)
    @images = find_images url
    image_violations
    generate_alt_text
  end

  def image_violations
    violations = 0
    @images.each do |image|
      violations += 1 unless image.attributes.to_s.include?('alt')
    end
    puts "\nWebpage has #{violations} violations of images without alternative text\n"
  end

  def debug
    ImageFix.methods
    y = 10
    binding.pry

  end

  def print_raw_images
    puts "\n"
    puts @images
    puts "\n"
  end

  def find_images(url)
    webpage = Nokogiri::HTML open url
    images = webpage.css 'img'
    puts "\nWebpage has #{images.length} images\n"
    images
  end

  def generate_alt_text
    @images.each_with_index do |image, i|
      img_src = get_img_src(image)
      puts "Image #{i}"
      puts img_src
      ImageRecognition.detect_labels(img_src)
    end
  end

  def self.generate_alt_text(image)
    img_src = self.get_img_src(image)
    ImageRecognition.detect_labels(img_src)
  end

  def get_img_src(image)
    image.attributes['src'].value
  end

  def self.get_img_src(image)
    image.attributes['src'].value
  end
end
