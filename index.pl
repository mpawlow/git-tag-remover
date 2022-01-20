#!/usr/bin/perl

# ------------------------------------------------------------------------------
# Copyright 2022 Mike Pawlowski
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ------------------------------------------------------------------------------

# Directives

use v5.32;
use strict;
use warnings;

# Version

our $VERSION = "v1.0.0";

# Modules

use Getopt::Long;

# Public Methods ------------------------------------------------------------->

sub main {
	
	my $releasePattern = "????-??-??_??-??-??";
	my $NUM_TAGS_TO_KEEP = 10;
	
	my $optNumTags = $NUM_TAGS_TO_KEEP;
	my $optGitDir = "";
	my $optPattern = $releasePattern;
	my $optHelp = "";
	
	GetOptions (
		'numtags|n=i' => \$optNumTags, 
		'gitdir|d=s' => \$optGitDir,
		'pattern|p=s' => \$optPattern,
		'help|h' => \$optHelp
	);	
	
	if ($optHelp ||
			!$optGitDir) {
		print "\n";
		print "Usage: perl index.pl [-n <integer>] [-d <string>] [-p <string>]\n";
		print "\n";
		print "--numtags | -n : Number of git tags to keep.\n";
		print "--gitdir  | -d : Directory of git repository.\n";
		print "--pattern | -p : Release tag pattern.\n";
		print "\n";
		print "e.g. perl index.pl -n 10 -d /c/Users/MikePawlowski/git/ngp-projects-api -p 'Release*'\n";
		print "\n";
		
		exit(0);
	}
	
	chdir($optGitDir) || die "Failed to change directory: ${optGitDir}.";
	
	my $gitCmdListTags = "git tag --list " . '"' . $optPattern . '"';
	my @tags = `$gitCmdListTags`;
	chomp(@tags);
	
	my $size = @tags;
	
	print "\n";
	print "Tags Found: ${size}\n\n";
	
	foreach my $tag (@tags){
		print "'$tag'\n";
	}

	print "\n";
	print "Tags To Keep: ${optNumTags}.\n";
	
	if ($size <= $optNumTags) {
		print "\n";
		print "Nothing to do.\n";
		exit(0);
	}
	
	my $endIndex = $size - $optNumTags;
	my @tagsToRemove = splice(@tags, 0, $endIndex);
	my $numTagsToRemove = @tagsToRemove;

	print "\n";
	print "Tags To Remove: ${numTagsToRemove}\n\n";

	foreach my $tag (@tagsToRemove) {
		print "'$tag'\n";
	}
	
	print "\n";
	print "Press <Enter> to continue or <Ctrl-C> to quit.\n";
	
	my $input = <STDIN>;
	my $gitCmdDeleteLocalTag = "git tag --delete ";
	my $gitCmdDeleteRemoteTag = "git push --delete origin ";
	my $status;

	foreach my $tag (@tagsToRemove) {

		print "\n";
		print "Deleting local tag: '${tag}' ...\n";
		
		$status = system("${gitCmdDeleteLocalTag} ${tag}");
		_doStatusCheck($status);
		
		print "\n";
		print "Deleting remote tag: '${tag}' ...\n";

		$status = system("${gitCmdDeleteRemoteTag} ${tag}");
		_doStatusCheck($status);
		
	}
	
	print "\n";
	print "Done.\n";
	exit(0);
	
}

# Private Methods ------------------------------------------------------------>

sub _doStatusCheck {
	
	my $status = shift;

	print "\n";

	if ($status == 0) {
		print "[OK]\n";
	} else {
		print "[FAIL] -- Status: ${?}.\n";
	}
	
}

# Main ----------------------------------------------------------------------->

main();
