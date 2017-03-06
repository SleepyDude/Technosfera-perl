package Anagram;

use 5.010;
use strict;
use warnings;
use utf8;
use Text::Levenshtein qw/distance/;
use Encode qw/encode decode/;
use Data::Dumper;
# use open qw(:std :utf8);
# use Encode qw(decode_utf8);
# BEGIN{ @ARGV = map decode_utf8($_, 1), @ARGV; }
=encoding UTF8

=head1 SYNOPSIS

Поиск анаграмм

=head1 anagram($arrayref)

Функцию поиска всех множеств анаграмм по словарю.

Входные данные для функции: ссылка на массив - каждый элемент которого - слово на русском языке в кодировке utf8

Выходные данные: Ссылка на хеш множеств анаграмм.

Ключ - первое встретившееся в словаре слово из множества
Значение - ссылка на массив, каждый элемент которого слово из множества, в том порядке в котором оно встретилось в словаре в первый раз.

Множества из одного элемента не должны попасть в результат.

Все слова должны быть приведены к нижнему регистру.
В результирующем множестве каждое слово должно встречаться только один раз.
Например

anagram(['пятак', 'ЛиСток', 'пятка', 'стул', 'ПяТаК', 'слиток', 'тяпка', 'столик', 'слиток'])

должен вернуть ссылку на хеш


{
    'пятак'  => ['пятак', 'пятка', 'тяпка'],
    'листок' => ['листок', 'слиток', 'столик'],
}

=cut

sub anagram {
    my $words_list = shift;
    my %result;
    my %w;
    foreach (@$words_list) {
    	my $word = decode('utf-8',$_);
    	$word = lc $word;
    	$word = encode('utf-8',$word);
    	# my $word = lc $_;
    	my $i = join('', sort split('', $word));
    	if (exists $w{$i}) {
    		next if $w{$i} =~ /$word/;
    		$w{$i} .= " ";
    	}
    	$w{$i} .= $word;
    }
    for (values %w) {
    	my @values = split(' ', $_);
    	my $first =  $values[0];
    	@values = sort @values;
    	$result{$first} = \@values if (scalar @values > 1);
    }

    

    return \%result;
}

1;
