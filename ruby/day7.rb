require_relative './lib/aoc'

Hand = Struct.new(:cards, :bid) do
  PT1_CARD_ORDER = '23456789TJQKA'.chars.each_with_index.to_h
  PT2_CARD_ORDER = 'J23456789TQKA'.chars.each_with_index.to_h

  def pt1_sort_key
    [type_for_tally(cards.tally), cards.map(&PT1_CARD_ORDER)]
  end

  def pt2_sort_key
    [type_for_tally(tally_with_wildcard_joker), cards.map(&PT2_CARD_ORDER)]
  end

  private def tally_with_wildcard_joker
    # replace joker with the most common card
    tally = cards.tally
    return tally if tally.length == 1
    j_count = tally.delete('J') || 0
    most_common_card = tally.entries.sort_by {_2}.last[0]
    tally[most_common_card] += j_count
    tally
  end

  private def type_for_tally(tally)
    counts = tally.values.sort
    return 6 if counts == [5] # 5 of a kind
    return 5 if counts == [1, 4] # 4 of a kind
    return 4 if counts == [2, 3] # full house
    return 3 if counts.include?(3) # 3 of a kind
    return 2 if counts == [1, 2, 2] # 2 pair
    return 1 if counts.include?(2) # pair
    0
  end
end

def sum_winnings(sorted_hands)
  sorted_hands.each_with_index.sum do |hand, index|
    hand.bid * (index + 1)
  end
end

input = AOC.get_input(7)
hands = input.split("\n").map do |line|
  cards, bid = line.split
  Hand.new(cards.chars, bid.to_i)
end

pt1 = sum_winnings(hands.sort_by(&:pt1_sort_key))
puts "Part 1: #{pt1}"

pt2 = sum_winnings(hands.sort_by(&:pt2_sort_key))
puts "Part 2: #{pt2}"