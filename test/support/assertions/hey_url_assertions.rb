require 'uri'
require 'cgi'

module Minitest::Assertions
  def assert_hey_urls_equal(expected, actual, msg = nil)
    differences = compare_hey_urls(expected, actual)
    
    if differences.empty?
      assert true # URLs are identical
    else
      failure_message = build_failure_message(differences)
      msg = message(msg) { failure_message }
      assert false, msg
    end
  end

  private

  def decode_ical_source(url)
    uri = URI(url)
    CGI.unescape(URI.decode_www_form(uri.query).to_h['ical_source']).split("\n")
  end

  def compare_hey_urls(url1, url2)
    ical1 = decode_ical_source(url1)
    ical2 = decode_ical_source(url2)
  
    differences = []
  
    # Compare each line of the decoded ical_source
    ical1.zip(ical2).each_with_index do |(line1, line2), index|
      if line1 != line2
        differences << {
          line_number: index + 1,
          expected_line: line2,
          actual_line: line1
        }
      end
    end
  
    # Handle case where one ical_source is longer than the other
    if ical1.length != ical2.length
      start = [ical1.length, ical2.length].min
      longer = ical1.length > ical2.length ? ical1 : ical2
      longer_label = ical1.length > ical2.length ? 'actual' : 'expected'
  
      longer[start..-1].each_with_index do |line, i|
        differences << {
          line_number: start + i + 1,
          "#{longer_label}_line": line,
          "#{longer_label == 'actual' ? 'expected_line' : 'actual_line'}": nil
        }
      end
    end
  
    differences
  end  

  def build_failure_message(differences)
    message = "Hey URLs do not match. Differences found:\n"
    differences.each do |diff|
      message << "Line #{diff[:line_number]}:\n"
      message << "  Expected: #{diff[:expected_line]}\n"
      message << "  Actual:   #{diff[:actual_line]}\n\n"
    end
    message
  end
end
