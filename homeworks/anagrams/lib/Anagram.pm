package Anagram;

use 5.010;
use strict;
use warnings;
use Encode qw/encode decode/;
use utf8;

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
    	my $i = join('', sort split('', $word));
    	next if (exists $w{$i} and exists $result{$word});
        push @{ $w{$i} }, $word;
        $result{$word} = [1];
        push @{ $result{encode('utf-8',$w{$i}[0])} }, $word;
    }
    foreach (keys %result) {
     	if (scalar @{ $result{$_} } < 2) {
             delete $result{$_};
        }
        else {
             @{ $result{$_} } = sort @{ $result{$_} };
            for my $var ( @{ $result{$_} } ) {
                $var = encode('utf-8',$var);
            }
        }
    }
    return \%result;
}

1;
