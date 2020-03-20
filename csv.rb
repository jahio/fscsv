#!/usr/bin/env ruby
#
# csv.rb
#   Given a CSV file named "in.csv", processes the information in that file
#   to generate a file, "out.csv" with only certain information. This is used
#   to extract the _meaningful_, _useful_ information from one large CSV into
#   a smaller, more streamlined CSV useful for programmatic import into another
#   Fivestars system.
#
# Author: J. Austin Hughey <joshua.hughey@fivestars.com>
#                          <jah@jah.io>
#

require 'csv'

#
# Output a header on the command prompt to let the user know what's
# going on.
# 
puts <<~EOF
  ********************************************************************************
                          Fivestars Export Cleanup Tool
  ********************************************************************************
EOF



#
# Check to see if we have args passed to the script. ARGV[0] should
# be the file the data is already in.
# 
if ARGV[0]
  puts "Input file specified as #{ARGV[0]}"
  in_file = ARGV[0]
else
  puts "Enter file location (drag file to window) or hit ENTER for default (in.csv):"
  file = gets.chomp
  if file.length < 1
    puts "Attempting to use default file in.csv"
    in_file = File.join(File.dirname(__FILE__), "in.csv")
  else
    puts "Looking for #{file}"
    in_file = file
  end
end

if File.exist?(in_file)
  puts "Found source CSV: #{in_file}"
else
  puts "Cannot find a valid CSV to import. #{in_file} doesn't exist."
  puts "Press ENTER to exit."
  gets.chomp
  exit 1
end

begin
  original_data = File.read(in_file)
rescue Errno::ENOENT
  puts "Enter input file location (full path):"
  in_file = gets.chomp
  original_data = File.read(in_file)
end

data = CSV.parse(original_data, headers: true)

out_file = ["phone", "name", "last_name", "email", "points", "birthday", "vip", "notes", "\n"].join(',')

row_count = 0

data.each do |row|
  # 
  # Check to ensure this is a viable candidate for export:
  # It MUST have EXACTLY 10 digits. No more. No less.
  #
  unless row['phone'] && row['phone'].length != 10
    #
    # Viable export candidate row; format data as needed.
    #
    # A lot of rows are going to have a blank birthday value, but we DO NOT
    # want to automatically make that 1/1 in the database, so we set it here to
    # nil to force a blank value in the CSV that results. Otherwise we just use
    # the value provided. Splitting the string here seems a more direct/easy/efficient
    # way than creating a new Date object.
    #  
    if row['birthday']
      birthday = "#{row['birthday'].split('-')[1]}/#{row['birthday'].split('-')[2]}"
    else
      birthday = nil
    end

    #
    # The order for this is:
    #   Phone, Name, Last Name, Email, Points, Birthday, VIP, Notes
    #
    out_file << [row['phone'], row['name'], nil, row['email'], row['points'], birthday, nil, row['notes'], "\n"].join(',')
  end
  row_count += 1
end

puts "Processed #{row_count} rows."

File.open(File.join(File.dirname(__FILE__), 'out.csv'), 'w') do |f|
  f.puts out_file
end

puts "Press ENTER to exit."
gets.chomp