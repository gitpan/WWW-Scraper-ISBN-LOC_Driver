package WWW::Scraper::ISBN::LOC_Driver;

use strict;
use warnings;
use HTTP::Request::Common;
use LWP::UserAgent;
use WWW::Scraper::ISBN::Driver;

our @ISA = qw(WWW::Scraper::ISBN::Driver);

our $VERSION = '0.22';

sub search {
	my $self = shift;
	my $isbn = shift;
	$self->found(0);
	$self->book(undef);
	# first, initialize the session:
        my $post_url = "http://lcweb.loc.gov/cgi-bin/zgate?ACTION=INIT&FORM_HOST_PORT=/prod/www/data/z3950/locils.html,z3950.loc.gov,7090";
        my $ua = new LWP::UserAgent;
        my $res = $ua->request(GET $post_url);
        my $doc = "";
        
        # get page
        # removes blank lines, DOS line feeds, and leading spaces.
        $doc = join "\n", grep { /\S/ } split /\n/, $res->as_string();
        $doc =~ s/\r//g;  
        $doc =~ s/^\s+//g;

	my $sessionID = "";

	unless ( ($sessionID) = ($doc =~ /<INPUT NAME="SESSION_ID" VALUE="([^"]*)" TYPE="HIDDEN">/i) ) {
		print "Error starting LOC Query session.\n" if $self->verbosity;
		$self->error("Cannot start LOC query session.\n");
		$self->found(0);
                return 0;
        }

        $post_url = "http://lcweb.loc.gov/cgi-bin/zgate";
        $res = $ua->request(POST $post_url, Referer => $post_url, Content => [ TERM_1 => $isbn, USE_1 => '7', ESNAME => 'F', ACTION => 'SEARCH', DBNAME => 'VOYAGER', MAXRECORDS => '20', RECSYNTAX => '1.2.840.10003.5.10', STRUCT_3 => '1', SESSION_ID => $sessionID]);
        
        $doc = "";
        
        # get page
        # removes blank lines, DOS line feeds, and leading spaces.
        $doc = join "\n", grep { /\S/ } split /\n/, $res->as_string();
        $doc =~ s/\r//g;  
        $doc =~ s/^\s+//g;

	if ( (my $book_data) = ($doc =~ /.*<PRE>(.*)<\/PRE>.*/is) ) {
                my $author = "";
                my @author_lines;
                my $other_authors;
                my $title;
                my $edition = 'n/a';
                my $volume = 'n/a';
                print $book_data if ($self->verbosity > 1);
                while ($book_data =~ s/uthor(s)?:\s+(\D+?)(?:, [0-9-.]*|\.)$/if (($1) && ($1 eq "s")) { "uthors:"; } else { "" }/me) { 
			my $temp = $2;
			$temp =~ s/ ([A-Z])$/ $1./; # trailing middle initial
                        push @author_lines, $temp;
                }
                @author_lines = sort @author_lines;
                foreach my $line(@author_lines) {
                        $line =~ s/(\w+), (.*)/$2 $1/;
                }
                $author = join ", ", @author_lines;
                                
                $book_data =~ /Title:\s+((.*)\n(\s+(.*)\n)*)/;
                $title = $1;
                $title =~ s/\n//g;
                $title =~ s/ +/ /g;
                $title =~ s/(.*) \/(.*)/$1/;
                print "title: $title\n" if ($self->verbosity > 1);;
                if ($book_data =~ /Edition:\s+(.*)\n/) {
			$edition = $1;
		} 
		if ($book_data =~ /Volume:\s+(.*)\n/) {
			$volume = $1;
		}
		print "author: $author\n" if ($self->verbosity > 1);
                print "edition: $edition\n" if ($self->verbosity > 1);
                print "volume: $volume\n" if ($self->verbosity > 1);
                my $bk = {
                        'isbn' => $isbn,
                        'author' => $author,
                        'title' => $title,
                        'edition' => $edition,
                        'volume' => $volume
                };
		$self->book($bk);
		$self->found(1);
                return $self->book;
        } else {
		print "Error extracting data from LOC result page.\n" if $self->verbosity;
		$self->error("Could not extract data from LOC result page.\n");
		$self->found(0);
                return 0;
        }
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

WWW::Scraper::ISBN::LOC_Driver - Searches Library of Congress's online catalog for book information.

=head1 SYNOPSIS

See parent class documentation (L<WWW::Scraper::ISBN::Driver>)

=head1 REQUIRES

Requires the following modules be installed:

=over 4

=item L<WWW::Scraper::ISBN::Driver>

=item L<Carp>

=item L<HTTP::Request::Common>

=item L<LWP::UserAgent>

=item L<Template::Extract>

=back

=head1 DESCRIPTION

Searches for book information from the Library of Congress's online catalog.  May be slower than most drivers, because it must 
first create a session and grab a session ID before perforiming a search.  This payoff may be worth it, if the catalog is more 
comprehensive than others, but it may not.  Use your best judgment.

=head2 EXPORT

None by default.

=head1 METHODS

=over 4

=item C<search()>

Starts a session, and then passes the appropriate form fields to the LOC's 
page.  If a valid result is returned, the following fields are available 
via the book hash:

  isbn
  author
  title
  edition
  volume

=back

=head1 SEE ALSO

=over 4

=item L<WWW::Scraper::ISBN>

=item L<WWW::Scraper::ISBN::Record>

=item L<WWW::Scraper::ISBN::Driver>

=back

No mailing list or website currently available.  Primary development done through CSX ( L<http://csx.calvin.edu/> )

=head1 AUTHOR

Andy Schamp, E<lt>andy@schamp.netE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2004 by Andy Schamp

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
