#!/usr/local/bin/ruby -w

require "rexml/document"

vulnerabilities = Hash.new

file = File.new( "full.xml" )
document = REXML::Document.new file

# for each IP address get the ids of the vulnerabilities found
document.root.elements.each("nodes/node") do | node |

  address = node.attributes["address"]
  ids = Array.new

  # there's definitely some code duplication following, but that's ok for now
  node.elements.each("tests/test") do | test |
    if test.attributes["status"].match(/^vul.*/)
      id = test.attributes["id"]
      ids.push(id)
    end
  end

  node.elements.each("endpoints/endpoint/services/service/tests/test") do | test|
    if test.attributes["status"].match(/^vul.*/)
      id = test.attributes["id"]
      ids.push(id)
    end
  end

  vulnerabilities[address] = ids

end

# create a vulnerability id to CVE mapping
cves = Hash.new
document.root.elements.each("VulnerabilityDefinitions/vulnerability") do | vulnerability |
  id = vulnerability.attributes["id"]
  vulnerability.elements.each("references/reference") do |reference|
    if reference.attributes["source"] =~ /CVE/
      cves[vulnerability.attributes["id"]] = reference.text     # this line is confusing and should be rewritten
    end
  end
end

# print out CVEs by IP address
vulnerabilities.each_key do |address|
  puts address
  ids = vulnerabilities[address]

  list = Array.new

  # create a list of all the CVEs (unique or not) for the current address using the ids
  ids.each do |id|
    if cves[id]
      list.push(cves[id])
    end
  end

  # output all unique CVEs for the current address
  puts list.uniq.sort
  puts "\n"
end
