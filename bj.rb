#Blackjack game

JACK= "Jack"
QUEEN= "Queen"
KING= "King"
ACE= "Ace"

ACE_VALUE = 11
ACE_VALUE_ALT = 1
FACE_CARD_VALUE = 10
DEALER_LIMIT = 17
BLACKJACK = 21

SUITS = ["Hearts", "Diamonds", "Spades", "Clubs"]
CARDS = ['2', '3', '4', '5', '6', '7', '8', '9', '10', JACK, QUEEN, KING, ACE]

CARD_SUIT = 0
CARD_VALUE = 1


# Calculate the total of the dealt cards
def calculate_total(cards) 
  # [['H', '3'], ['S', 'Q'], ... ]
  # first create an array of just the values, not the suits

  #the map method creates a new array based on the block
  card_values = cards.map{|a_card| a_card[CARD_VALUE] }

  total = 0
  card_values.each do |value|
    if value == ACE
      total += ACE_VALUE    # an ace can be valued at 1 or 11, use 11 first
    elsif value.to_i == 0   # J, Q, K - to_{} will return 0 if non-numeric input
      total += FACE_CARD_VALUE  # for those cases the card value is 10
    else
      total += value.to_i   
    end
  end

  #correct for Aces, if we have blown over 21
  card_values.select{|value| value == ACE}.count.times do
    total -= (ACE_VALUE - ACE_VALUE_ALT) if total > BLACKJACK
  end

  total

end

#Create string for the card, to print
def print_card (card)
  card[CARD_VALUE] + " of "  + card[CARD_SUIT] 
end

def print_initial_total(who_has, cards, total)
  puts who_has + " has: " + print_card(cards[0]) + " and " + print_card(cards[1]) + ", for a total of #{total}"
end

def print_dealt_cards(cards)
  cards.each do |a_card|
    puts "=> " + print_card(a_card)
  end
end

# get a choice from the player
def get_choice(message, choice_1, choice_2)
  puts message
  input = choice_1
  loop do
    input = gets.chomp
  
    if ![ choice_1, choice_2].include?(input)
      puts "Error: you must enter #{choice_1} or #{choice_2}"
    else
      break
    end
  end
  input  
end

#Main blackjack method
def blackjack

  # This initializes the deck
  deck = SUITS.product(CARDS)
  
  # while the player nor dealyer has 21, or the player or dealer does not go bust (over 21)
  # dealer deals one card to player, then himself;  (Those cards are removed)
  
  # if player says hit, dealer deals another card to player and himself.
  
  puts "Shuffling cards... (you can trust me.  I'm a Ruby program)"
  deck.shuffle!
  
  # Deal Cards
  
  mycards = []
  dealercards = []
  
  mycards << deck.pop
  dealercards << deck.pop
  mycards << deck.pop
  dealercards << deck.pop
  
  dealertotal = calculate_total(dealercards)
  mytotal = calculate_total(mycards)
  
  # Show Cards
  
  # puts "Dealer has: #{dealercards[0]} and #{dealercards[1]}, for a total of #{dealertotal}"
  #print_initial_total("Dealer", dealercards, dealertotal)
  dealer_first_card = []
  dealer_first_card << dealercards[0]
  puts "Dealer shows one card: #{print_card(dealercards[0])}, for a total of #{calculate_total(dealer_first_card)}"
  puts "Player has: #{print_card(mycards[0])} and #{print_card(mycards[1])} , for a total of #{mytotal}"

  puts ""
    
  while mytotal < BLACKJACK
  
    if get_choice("What would you like to do? 1) hit 2) stay", '1', '2') == '2'
      puts "Stay!"
      break
    end
   
    # hit me!
    puts "Hit me!"
    new_card= deck.pop
    puts "Dealing card to player: #{print_card(new_card)}"
    mycards << new_card
  
    mytotal = calculate_total(mycards)
    puts "Your total is now #{mytotal}"
    
    if mytotal == BLACKJACK
      puts "Congratulations, you hit 21! You win!"
      return
    elsif mytotal > BLACKJACK
      puts "Sorry, it looks like you busted!"
      return
    end
  end
  
  # Dealer turn
  
  if dealertotal == BLACKJACK
    puts "Dealer wins- blackjack!"
    return
  end
    
  while dealertotal < DEALER_LIMIT
    # dealer hit
    new_card= deck.pop
    puts "Dealing new card for dealer: #{print_card(new_card)}"
    dealercards << new_card
    
    dealertotal = calculate_total(dealercards)  
    puts "Dealer total is now: #{dealertotal}"
    
    if dealertotal == BLACKJACK
      puts "Dealer has 21- dealer wins!"
      return
    elsif dealertotal > BLACKJACK
      puts "Dealer busted- player wins!"  
      return
    end
    
  end
  
  puts "Dealer's cards:"
  print_dealt_cards(dealercards)
  puts ""
  
  puts "Your cards:"
  print_dealt_cards(mycards)
  puts ""
  
  if dealertotal > mytotal
    puts "Dealer total is greater than player total- dealer wins!"
  elsif dealertotal < mytotal
    puts "Congratulations, you win!"
  else
    puts "It's a tie!"
  end
  
end

puts "Welcome to Blackjack!"

#main loop
loop do
  
  blackjack  
  
  break if get_choice("Would you like to play again? y)yes or n)no", 'y', 'n') == 'n'
  
end
