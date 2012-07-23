#!/usr/bin/env ruby

colors = {
    "section" => "02;01",
    "comment" => "37",
    "normal"  => "00",
    "A"       => "32",
    "NS"      => "34",
    "CNAME"   => "36",
    "SOA"     => "33",
    "MX"      => "31",
}

IO.popen("dig " + ARGV.join(" ")) { |io|
    io.each_line { |line|
        color = colors["normal"]
        if line =~ /^;;.+SECTION:$/
            color = colors["section"]
        elsif line =~ /^;/
            color = colors["comment"]
        elsif line =~ /^(.+\s)(SOA|NS|A|MX|CNAME)(\s.+)$/
            color = colors[$2]
        end
        printf "\e[%sm%s\e[00m", color, line
    }
}
