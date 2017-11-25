#!/usr/bin/env ruby
# coding: utf-8

# <bitbar.title>Agenda</bitbar.title>
# <bitbar.version>v0.1</bitbar.version>
# <bitbar.author>yqrashawn</bitbar.author>
# <bitbar.author.github>yqrashawn</bitbar.author.github>
# <bitbar.desc>display emacs org-agenda in bitbar</bitbar.desc>
# <bitbar.image> http://yqrashawn.com/2017/11/25/org-agenda-bitbar-plugin/2017-11-25_bitbar-ext-org-agenda - scaled width 500.png</bitbar.image>
# <bitbar.dependencies>ruby</bitbar.dependencies>

require 'open3'

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

# Change to your todo directory path
agenda_directory = "#{Dir.home}/agendas/work/"
agenda_name = 'todos.txt'

# Change priority color here
tag_color = 'orange'

# Customise label color-code here (these colors are optimised for a dark theme menubar)
labels = {
  '[#A]' => 'red',
  '[#B]' => 'yellow',
  '[#C]' => 'violet'
}

tag_indicator = 'Headlines with TAGS match: '

# close stdout stderr
system '/usr/local/bin/emacs',
       '--batch',
       '-l',
       '~/.emacs.d/init.el',
       '--eval',
       '(run-hooks \'emacs-startup-hook)',
       '--eval',
       "(progn (org-agenda nil \"B\") (org-agenda-write \"#{agenda_directory}#{agenda_name}\") (spacemacs/kill-emacs))",
       :out => :close,
       :err => :close

agenda_file = File.open("#{agenda_directory}#{agenda_name}")

lines = IO.readlines(agenda_file)

puts "Do: #{lines.length}"
puts '---'

# remove empty line
lines.reject! { |s| s.nil? || s.strip.empty? }
lines.reject! { |s| s.include?('=====') }
lines.each.with_index do |line, i|
  # get url for urls [[https://example.com][example]]
  url = ''
  if line.include?('[[http')
    url = line.slice(/\[\[((http?|ftp).*\]\[)/)
    lines[i] = line.sub(url, '')
    lines[i] = lines[i].sub ']]', ''
    line = lines[i]
    url = url.slice(2, url.length - 4)
  end

  # detect tag line
  if line.include?(tag_indicator)
    lines[i] = "#{line.slice(tag_indicator.length, line.length).delete("\n")} | color=#{tag_color} font=Hack"
  else
    # get color dpends on priority
    line_color = ''
    labels.each { |label, label_color| line_color = label_color if line.include?(label)}
    line_color = 'white' if line_color.strip.empty?

    # remove TODO, add color, special font for clickable one
    lines[i] = "#{line.delete("\n").squeeze(' ')}|color=#{line_color} #{url.strip.empty? ? '' : "font=Hack bash=open param1=" + "'" + url + "'" + " terminal=true"}"
  end
end

puts lines
# :(:?[a-z]+:?)*:$