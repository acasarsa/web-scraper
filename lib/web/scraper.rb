# require "web/scraper/version"
require 'kimurai'


class JobScraper < Kimurai::Base
  @name = 'eng_job_scraper' #name of scraper
  @start_urls = ["https://www.indeed.com/jobs?q=software+engineer&l=New+York%2C+NY"] # array of start urls to process one by one inside the parse method
  @engine = :selenium_chrome # engine used for scraping
  @@jobs = []

  def scrape_page 
    # puts 'go to sleep for reload ...'
    sleep 3
    doc = browser.current_response
    returned_jobs = doc.css('td#resultsCol')
    returned_jobs.css('div.jobsearch-SerpJobCard').each do |char_element|
      #scraping indv listings
      title = char_element.css('h2 a')[0].attributes["title"].value.gsub(/\n/, "") # nokogiri creates an array so must use array notation
      link = "https://indeed.com" + char_element.css('h2 a')[0].attributes["href"].value.gsub(/\n/, "")
      description = char_element.css('div.summary').text.gsub(/\n/, "")
      company = description = char_element.css('span.company').text.gsub(/\n/, "") # does this work right? 
      location = char_element.css('div.location').text.gsub(/\n/, "")
      salary = char_element.css('div.salarySnippet').text.gsub(/\n/, "")
      requirements = char_element.css('div.jobCardReqContainer').text.gsub(/\n/, "")

      job = {title: title, link: link, description: description, company: company, location: location, salary: salary, requirements: requirements}

      @@jobs << job if !@@jobs.include?(job)
    end # char_el do end ends here
  end # scrape_page ends here

  # def parse(response, url:, data: {} )
  #   # scrape first page    
  #   scrape_page    
  #   puts "🔹 🔹 🔹 CURRENT NUMBER OF JOBS: #{@@jobs.count}🔹 🔹 🔹"   
  #   puts "🔺 🔺 🔺 🔺 🔺  CLICKED THE NEXT BUTTON 🔺 🔺 🔺 🔺 "

  #   CSV.open('jobs.csv', "w") do |csv|
  #     csv << @@jobs
  #   end

  #   File.open("jobs.json","w") do |f|
  #     f.write(JSON.pretty_generate(@@jobs))
  #   end

  #   @@jobs
  # end # parse method ends here
  
  def parse(response, url:, data: {})
    scrape_page
    num = 1
    10.times do
      # scrape_page
      browser.visit("https://www.indeed.com/jobs?q=software+engineer&l=New+York,+NY&start=#{num}0")
      scrape_page
      num += 1

      # if browser.current_response.css('div#popover-background') || browser.current_response.css('div#popover-input-locationtst')
      #   puts 'popup ...' 
      #   browser.refresh 
      #   sleep 2
      # end
              
      # browser.find('/html/body/table[2]/tbody/tr/td/table/tbody/tr/td[1]/nav/div/ul/li[6]/a/span').click
      puts "🔹 🔹 🔹 CURRENT NUMBER OF JOBS: #{@@jobs.count}🔹 🔹 🔹"
      # puts "🔺 🔺 🔺 🔺 🔺  CLICKED NEXT BUTTON 🔺 🔺 🔺 🔺 "
    end

    CSV.open('jobs.csv', "w") do |csv|
        csv << @@jobs
    end

    File.open("jobs.json","w") do |f|
        f.write(JSON.pretty_generate(@@jobs))
    end
    
    @@jobs
  end

  
end # class ends here

puts 'starting scrape...'
jobs = JobScraper.crawl!
puts 'scraping complete...'

# element click intercepted: Element <span class="pn">...</span> is not clickable at point (354, 300). Other element would receive the click: <input name="email" type="email" id="popover-email" class="popover-input-locationtst"> (Selenium::WebDriver::Error::ElementClickInterceptedError)
