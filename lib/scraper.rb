require 'open-uri'
require 'pry'

class Scraper

  def self.scrape_index_page(index_url)
    index_page = Nokogiri::HTML(open(index_url))

    students = index_page.css("div.roster-cards-container").collect do |card|
      card.css(".student-card a").collect do |student|
        {
          name: student.css(".student-name").text,
          location: student.css(".student-location").text,
          profile_url: "#{student.attr('href')}"
        }
      end
    end.flatten
  end

  def self.scrape_profile_page(profile_url)
    student_page = Nokogiri::HTML(open(profile_url))

    socials = student_page.css("div.social-icon-container").collect do |container|
      container.css("a").collect do |social|
        "#{social.attr('href')}"
      end
    end.flatten

    { twitter: socials.grep(/twitter/)[0], 
      linkedin: socials.grep(/linkedin/)[0],
      github: socials.grep(/github/)[0],
      blog: socials.grep(/^((?!twitter).)*$/).grep(/^((?!linkedin).)*$/).grep(/^((?!github).)*$/)[0],
      profile_quote: student_page.css(".profile-quote").text,
      bio: student_page.css("div.bio-content div.description-holder").text.gsub(/\n\ */,"")
    }.compact
  end

end

