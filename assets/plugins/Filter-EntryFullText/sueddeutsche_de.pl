use HTML::Scrubber;

sub handle {
    my($self, $args) = @_;
    $args->{entry}->permalink =~ m!http://www.sueddeutsche.de!;
}

sub extract {
  my($self, $args) = @_;

#my @lines = <>;
#my $str = join('',@lines);

  my $str = $args->{content};

  if ($str =~ m#<div class="artikelheader clr">.*?(<div class="main content.*?)<table class="bgf2f2f2 absatz">#ms) {
    print "match\n";
    my $body = $1;

    $body =~ s#<!-- Stoerer //-->.*?<!-- END Stoerer //-->##ms;
    $body =~ s#<!-- performance media -->.*?<!-- //performance media -->##ms;
    $body =~ s#<span>\s*Anzeige\s*</span>##msi;
    $body =~ s#<p class="bannerAnzeige">ANZEIGE</p>##msi;
    $body =~ s#<span class="bannerAnzeige">ANZEIGE</span>##msi;

    my $scrubber = HTML::Scrubber->new( 
      deny => [ qw[ div noscript iframe ] ],
      default => 1,
    );
    $scrubber->rules(img => { "*" => 1 });
    $body = $scrubber->scrub($body);
    return($body);
  }
  else {
    return;
  }
}
