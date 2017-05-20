require 'rubygems'
require 'nokogiri'
require 'open-uri'
require_relative 'image_recognition.rb'

class ImageFinder
  attr_reader :images

  def initialize(url)
    @images = find_images url
    generate_alt_text
  end

  def find_images(url)
    webpage = Nokogiri::HTML open url
    webpage.css 'img'
  end

  def generate_alt_text
    @images.each_with_index do |image, i|
      img_src = get_img_src(image)
      puts i
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

  def each &prc
    (0..@images.length).each do |image|
      prc.call(image)
    end
    @images
  end
end
