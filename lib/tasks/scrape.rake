require 'mechanize'
require 'nokogiri'

namespace :scrape do
  BASE_URL = "https://class-search.nd.edu/reg/srch/ClassSearchServlet"

  desc "Scrape the departments from the University of Notre Dame course search website."
  task scrape_departments: :environment do
    browser = Mechanize.new
    search_form = browser.get(BASE_URL).form()

    subject_select = search_form.field_with(:name => "SUBJ")

    puts subject_select
    subj_options = subject_select.options

    subj_options.each do |option|
      dept = Department.find_or_initialize_by(tag: option.value.strip)

      if dept.new_record?
        puts "#{option.value.strip} is a new department!"
        dept.name = option.text.strip
        dept.save
        puts "Created new department!"
      end
      #puts "#{option.value.strip} - #{option.text.strip}"
    end
  end

  desc "Scrape the classes from the University of Notre Dame course search website."
  task scrape_classes: :environment do
    #get_first_term
    get_classes
  end

  desc "Update the number of seats from the University of Notre Dame course search website."
  task update_classes: :environment do
  end

  desc "TODO"
  task scrape_descriptions: :environment do
  end


  def get_classes
    @departments = Department.all

    browser = Mechanize.new
    search_form = browser.get(BASE_URL).form()
    subject_select = search_form.field_with(:name => "SUBJ")
    year_select = search_form.field_with(:name => "TERM")
    year_tag = year_select.options.first.value.strip

    subject_select.select_all()
    #subject_select.value = subject_select.options.first.value

    response = browser.submit(search_form)
    results = response.body

    doc = Nokogiri::HTML(results, 'UTF-8')

   #puts doc
    parse_html(doc, year_tag)
  end

  def get_first_term
    browser = Mechanize.new
    search_form = browser.get(BASE_URL).form()
 #   subject_select = search_form.field_with(:name => "SUBJ")
    year_select = search_form.field_with(:name => "TERM")

    year_name = year_select.options.first.text.strip
    year_tag = year_select.options.first.value.strip

    term = Term.find_or_initialize_by(tag: year_tag)

    if term.new_record?
      puts "New term!"
      term.name = year_name
      term.save
    else
      term.name =  year_name
      #term.save
    end
  end

  def parse_html(html, year_tag)

    # Resulting Table Rows from the Form Submission
    rows = html.xpath('//table[@id="resulttable"]/tbody/tr')

    puts rows.text.strip
    #puts rows.length

    details = rows.collect do |row|
              detail = {}
                  [
                    #[:subject, subject],
                    [:course, 'td[1]/a[1]'],
                    [:section, 'td[1]/a[1]'],
                    [:title, 'td[2]'],
                    [:credits, 'td[3]'],
                    [:status, 'td[4]'],
                    [:max_spots, 'td[5]'],
                    [:open_spots, 'td[6]'],
                    [:xlst, 'td[7]'],
                    [:crn, 'td[8]'],
                    [:syl, 'td[9]'],
                    [:instructor, 'td[10]/a'],
                    [:when, 'td[11]'],
                    [:begin, 'td[12]'],
                    [:end, 'td[13]'],
                    [:location, 'td[14]']
                  ].each do |name, xpath|
                    if name == :course
                      detail[name] = row.xpath(xpath).text.strip.split('-').first.strip
                    elsif name == :section
                      detail[name] = row.xpath(xpath).text.strip.split('-').last.strip
                    else
                      detail[name]=row.xpath(xpath).text.strip
                    end
                  end
            course = Course.find_or_initialize_by(course_number: detail[:course])


            tag, number = detail[:course].match(/(?<tag>[A-Z]{2,8})(?<number>\d{2,6})/i).captures

           # puts "#{tag}-#{number}"

            dept = Department.find_or_initialize_by(tag: tag)
            term = Term.last

            #puts term.name
            #puts dept.name

            if course.new_record?
              puts "Adding #{detail[:title]}"
              course.title = detail[:title]
              course.credits = detail[:credits]
              course.course_number = detail[:course]
              course.department = dept
              course.term = term
              course.save
            else
              puts "#{detail[:title]} already exists"
              #course.title = detail[:title]
              #course.credits = detail[:credits]
              #course.course_number = detail[:course]
              #course.department = dept
              #course.term = term
              #course.save
            end
    end
    #puts "Printed classes"
  end
end
