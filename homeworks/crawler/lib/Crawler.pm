package Crawler;

use 5.010;
use strict;
use warnings;

use AnyEvent::HTTP;
use Web::Query;
use DDP;
use URI::URL;

=encoding UTF8

=head1 NAME

Crawler

=head1 SYNOPSIS

Web Crawler

=head1 run($start_page, $parallel_factor)

Сбор с сайта всех ссылок на уникальные страницы

Входные данные:

$start_page - Ссылка с которой надо начать обход сайта

$parallel_factor - Значение фактора паралельности

Выходные данные:

$total_size - суммарный размер собранных ссылок в байтах

@top10_list - top-10 страниц отсортированный по размеру.

=cut

my @urls;
my %hrefs;
my %hrefs_text;

sub run {
    my ($start_page, $parallel_factor) = @_;
    $start_page or die "You must setup url parameter";
    $parallel_factor or die "You must setup parallel factor > 0";

    $AnyEvent::HTTP::MAX_PER_HOST = $parallel_factor;

    my $total_size = 0;
    my @top10_list;
    
    push @urls, $start_page;
    my $quoted_start_page = quotemeta($start_page);

    my $counter = 0;
    my @new_urls;

	my $cv = AnyEvent->condvar; $cv->begin;

	my $next; $next = sub {
		my $url = shift @urls;
		return if not $url;
		$cv->begin;
		http_head $url, sub {
			my ($body, $hdr) = @_;
			if ($hdr->{"content-type"} =~ "text/html") {
				$counter++;
				return if $counter > 1000;
				$cv->begin;
				http_get $url, sub {
					my ($body, $hdr) = @_;
					die("Fail $url: @$hdr{qw(Status Reason)}") if ($hdr->{Status} != 200);
					$hrefs_text{$url} = $hdr->{"content-length"};
					wq($body)
						->find('a')
						->each(sub {
							my $i = shift;
							my $href = $_->attr('href');
							$href =~ /^(.*?)(?:#|$)/;
							$href = $1;
							my $new_abs = URI->new_abs($href, $start_page)->canonical;
							if (!exists $hrefs{$new_abs}) {
								$hrefs{$new_abs} = 1;
								push @urls, $new_abs if $new_abs =~ $quoted_start_page;
							}
						});
					$next->();
					$cv->end;	
				};
			}			
			$next->();
			$cv->end;
		};
	}; $next->() for 1..$parallel_factor;
	$cv->end; $cv->recv;

	foreach my $href (sort { $hrefs_text{$a} <=> $hrefs_text{$b} } keys %hrefs_text) {
		say "$href  $hrefs_text{$href}";
		$total_size += $hrefs_text{$href};
	}

	for my $key ((sort { $hrefs_text{$b} <=> $hrefs_text{$a} } keys %hrefs_text)[0..9]) {
		push @top10_list, $key;
	}

    return $total_size, @top10_list;
}

1;
