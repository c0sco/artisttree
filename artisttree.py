#!/usr/bin/env python

# Matt Stofko
# January 2012

import sys
import urllib2
import re
from xml.sax import saxutils
import colorama

wikiRoot = r'http://en.wikipedia.org'

def main():
	global wikiRoot
	totalSeen = []
	colorama.init()

	# Grab the URL we were passed (main band)
	content = getUrlContent(sys.argv[1])

	# Get the band name and remember that we've seen it
	bandName = getBandName(content)
	totalSeen.append(bandName)

	# Get all the members of the band (current)
	members = parseMembers(content)

	# Get associated acts
	acts = parseAssocActs(content)

	totalActs = []
	# For each band in the associated acts list
	for band in acts:
		# If we haven't seen it yet
		if band not in totalActs:
			# Add the stuff we find for it and remember we saw it
			totalActs.append(runBand(band, members))
			totalSeen.append(band[1])

	# Print the header
	print tableHeader(bandName)

	# and print out all of the acts we found
	for band in totalActs:
		print "|- " + boldIt(band[1]), "(because of:", ", ".join([b[1] for b in band[2]]) + ")"
		nextContent = getUrlContent(wikiRoot + band[0])
		nextActs = parseAssocActs(nextContent)
		nextMembers = parseMembers(nextContent)

		if nextMembers == []:
			nextMembers = band[2]

		for nact in nextActs:
			if nact[1] in totalSeen:
				continue

			nextBand = runBand(nact, nextMembers)

			# We found no reason these were related, the name is just mentioned in the article by the author
			if nextBand[2] == []:
				nextBand[2].append(("", "a Wikipedia author saying so"))

			print "| `- " + boldIt(nextBand[1]), "(because of:", ", ".join([b[1] for b in nextBand[2]]) + ")"
			totalSeen.append(nextBand[1])

	# Footer and done
	print tableFooter(bandName)
	return


def runBand(band, members):
	global wikiRoot

	### XXX handle "Touring members" section (e.g. pat smear/nirvana)
	### XXX or also a Members section at the bottom (e.g. Wool)

	# Get the content of the wiki page for it
	actContent = getUrlContent(wikiRoot + band[0])

	# Look for the current members of the band this is associated with it to see why it's an associated act
	reasons = []
	nextMembers = parseMembers(actContent)
	for member in members:
		if member in nextMembers:
			reasons.append(("", member[1]))

	# Didn't find a match between the member lists, just look for members anywhere on the page
	if reasons == []:
		for member in members:
			if actContent.find(member[1]) > 0:
				reasons.append(("", member[1]))

	return (band[0], band[1], reasons)


# Parse the members page
def parseMembers(content):
	allMembers = []

	for key in ('Members</th>\n</tr>', 'Past members</th>\n</tr>'):
		start = content.find(key) + len(key)

		if start == len(key) - 1:
			# We didn't find the section, skip this round
			continue

		end = content[start:].find('</tr>')
		allMembers += re.findall(r'<a href="(.*?)" title=".*?">(.*?)</a>', content[start:start+end])

	return allMembers


# Parse the associated acts
def parseAssocActs(content):
	# Find the Associated acts table so we can only match against that
	x = content.find('Associated acts</th>')
	y = content[x:].find('</tr>')

	return re.findall(r'<a href="(.*?)" title=".*?">(.*?)</a>', content[x:x+y])


# Parse the title
def parseTitle(content):
	found = re.findall(r'class="firstHeading">.*?<span dir="auto">(.*?)</span>', content, re.DOTALL)

	if found:
		return found[0]
	else:
		return ""


# Open a url and return its contents
def getUrlContent(url):
	url = saxutils.unescape(url)

	try:
		return urllib2.urlopen(urllib2.Request(url, headers={'User-Agent': "Safari WebKit"}) ).read()
	except:
		print "Could not get contents of", url
		return ""


# Get the band name from the page (the title of the article)
def getBandName(content):
	bandName = parseTitle(content)
	badName = re.match(r'(.*?) \(band\)$', bandName)

	if badName and len(badName.groups()) > 0:
		return badName.groups()[0]
	else:
		return bandName

# Return the table header to be printed
def tableHeader(bandName):
	return boldIt(bandName) + ' ' + '-' * 4


# Return the table footer to be printed
def tableFooter(bandName):
	return "-" * (len(bandName) + 5)


# Bold some text
def boldIt(text):
	return colorama.Style.BRIGHT + text + colorama.Style.RESET_ALL


if __name__ == "__main__":
	if len(sys.argv) != 2 or sys.argv[1].find(wikiRoot + '/wiki/') != 0:
		print "Must pass a wikipedia URL to begin at."
		exit()

	main()
	exit()
