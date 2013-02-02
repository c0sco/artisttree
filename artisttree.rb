#!/usr/bin/env ruby

require 'open-uri'
require 'term/ansicolor'
include Term::ANSIColor

$wikiRoot = 'http://en.wikipedia.org'

def main
	# Where we will store our bands as we find them
	totalSeen = []

	# Can we get to the URL we've been given?
	content = getUrlContent(ARGV[0])
	if not content
		puts "Could not get contents of #{ARGV[0]}"
		exit
	end

	# Parse the band name out of the HTML (instead of trying to figure out the URL)
	bandName = getBandName(content)
	if not bandName
		puts "Could not get band name"
		exit
	end

	totalSeen.push(bandName)

	# Get all the members of the band (current)
	members = parseMembers(content)

	# Get associated acts
	acts = parseAssocActs(content)

	totalActs = []
	# For each band in the associated acts list
	for band in acts
		# If we haven't seen it yet
		if not totalActs.include?(band)
			# Go get it and remember that we've processed it so we don't do it again
			totalActs.push(runBand(band, members))
			totalSeen.push(band[1])
		end
	end

	# Output time!

	puts tableHeader(bandName)

	# For all of our associated acts
	for band in totalActs
		puts "|- " + bold(band[1]) + " (because of: " + band[2].map {|b| b[1]}.join(', ') + ')'

		# ... and THEIR associated acts (level 2 of the tree)
		nextContent = getUrlContent($wikiRoot + band[0])
		nextActs = parseAssocActs(nextContent)
		nextMembers = parseMembers(nextContent)

		if nextMembers.empty?
			nextMembers = band[2]
		end

		for nact in nextActs
			if totalSeen.include?(nact[1])
				next
			end

			nextBand = runBand(nact, nextMembers)

			# A band was referenced as associated but we can't figure out why
			if nextBand[2].empty?
				nextBand[2].push(["", "a Wikipedia author saying so"])
			end

			puts "| `- " + bold(nextBand[1]) + " (because of: " + nextBand[2].map {|b| b[1]}.join(', ') + ')'

			totalSeen.push(nextBand[1])
		end
	end

	puts tableFooter(bandName)
end

# Grab the contents of a URL and return it
def getUrlContent(url)
	begin
		return open(url, "User-Agent" => "Safari WebKit").read
	rescue
		return ""
	end
end

# Parse out the band name given the wikipedia HTML document of said band
def getBandName(content)
	bandName = parseTitle(content)

	# Look for things like "Nirvana (band)", we know it's a band, we don't need to print that
	if badName = /(.*?) \(band\)$/.match(bandName)
		return badName[1]
	else
		return bandName
	end
end

# Do the lifting for getBandName. Actually finds the name in the HTML
def parseTitle(content)
	if found = /class="firstHeading".*?<span dir="auto">(.*?)<\/span>/m.match(content)
		return found[1]
	else
		return ""
	end
end

# Grab the members and past members for a band
def parseMembers(content)
	allMembers = []

	for key in ["Members</th>\n</tr>", "Past members</th>\n</tr>"]
		start = content.index(key)
		if start
			start += key.length
		else
			next
		end

		ending = content[start..-1].index('</tr>')
		found = content[start..start+ending].scan(/<a href="(.*?)" title=".*?">(.*?)<\/a>/)
		for x in found
			allMembers.push(x)
		end
	end

	return allMembers
end

# Parse the associated acts for a band
def parseAssocActs(content)
	# Find the Associated acts table so we can only match against that
	x = content.index('Associated acts</th>')
	y = content[x..-1].index('</tr>')

	return content[x..x+y].scan(/<a href="(.*?)" title=".*?">(.*?)<\/a>/)
end

# Given a band, figure out why they are associated to their associated acts
def runBand(band, members)
	### XXX handle "Touring members" section (e.g. pat smear/nirvana)
	### XXX or also a Members section at the bottom (e.g. Wool)

	# Get the content of the wiki page for it
	actContent = getUrlContent($wikiRoot + band[0])

	# Look for the current members of the band this is associated with it to see why it's an associated act
	reasons = []
	nextMembers = parseMembers(actContent)
	for member in members
		if nextMembers.include?(member)
			reasons.push(["", member[1]])
		end
	end

	# Didn't find a match between the member lists, just look for members anywhere on the page
	if reasons.empty?
		for member in members
			#puts "member1 is #{member[1]}, index is ", actContent.index(member[1])
			if actContent.index(member[1])
				reasons.push(["", member[1]])
			end
		end
	end

	return [band[0], band[1], reasons]
end

def tableHeader(bandName)
	return bold(bandName) + ' ' + '-' * 4
end

def tableFooter(bandName)
	return "-" * (bandName.length + 5)
end

main
