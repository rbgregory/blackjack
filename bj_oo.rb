ACE= "Ace"
ACE_VALUE = 11
ACE_ALT_VALUE = 1
BLACKJACK = 21
DEALER_LIMIT = 17

class Participant
  attr_reader :name

  def set_name(name)
    @name= name
    @hand= Hand.new
  end
  
  def << (card)
    @hand << card
  end
  
  def show_hand
    hand.show
  end
  
  def hand_value
    hand.calculate_total
  end
  
  def to_s
    show_hand
  end
  
protected
  attr_reader :hand
end

class Dealer < Participant
  attr_accessor :talk, :show_all
  
  def initialize
    set_name("Dealer")
    @deck= Deck.new
    @deck.shuffle
    @show_all=false
    @talk=false
  end
  
  def deal_to(participant)
    card = @deck.pop
    participant << card
    puts "Dealer deals #{card}" if talk == true
  end
  
  def show_hand
    if @show_all
      super
    else
      "(Hidden), #{hand[1]}"
    end
  end
  
  def hand_value
    unless @show_all 
      hand[1].value
    else
      super
    end
  end
end

class Player < Participant
  def initialize
    set_name("Player")
  end
  
  # get a choice from the player
  def decide
    input = '0'
    puts "What would you like to do? 1) hit 2) stay"
    loop do
      input = gets.chomp
      if !['1', '2'].include?(input)
        puts "Error: you must enter 1 or 2"
      else
        break
      end
    end
    puts "Hit me!" if input == '1'
    puts "Stay!" if input == '2'
    input  
  end
end

class Card
  attr_reader :suit, :face, :value
  
  def initialize(suit, face, value)
    @suit = suit
    @face = face
    @value = value
  end

  def to_s
    "#{face} of #{suit}"
  end
  
end

class Hand
public
  def initialize
    @cards = Array.new
  end
  
  def << (card)
    cards << card
  end
  
  def show
    "#{cards.join(", ")}"
  end
  
  # Calculate the total of the dealt cards
  def calculate_total
    total = 0
    cards.each {|a_card| total += a_card.value }
    #correct for Aces, if we have blown over 21
    cards.each do |a_card| 
      if a_card.face == ACE 
        total -= (ACE_VALUE - ACE_ALT_VALUE) if total > BLACKJACK
      end
    end
    total
  end

  def [] (idx)
    cards[idx]
  end
private
  attr_accessor :cards
end

class Deck
  JACK= "Jack"
  QUEEN= "Queen"
  KING= "King"
  SUITS = ["Hearts", "Diamonds", "Spades", "Clubs"]
  FACE = ['2', '3', '4', '5', '6', '7', '8', '9', '10', JACK, QUEEN, KING, ACE]
  VALUE = [2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10, 10, 11]
  
  def initialize
    @deck= Array.new
    SUITS.each do |suit|
      FACE.each_index do |idx|
        @deck.push Card.new(suit, FACE[idx], VALUE[idx]) 
      end
    end
  end

  def shuffle
    @deck.shuffle!
  end
  
  def pop
    @deck.pop
  end
  
  def print
    @deck.each { |card| puts "#{card}" }
  end
end

class Game
  attr_reader :dealer, :player
  
  def initialize
    @dealer = Dealer.new
    @player = Player.new
  end
  
  def show_player
    puts "Player: #{player}, value= #{player.hand_value}"
  end
  
  def show_dealer
    puts "Dealer: #{dealer}, value= #{dealer.hand_value}"
  end
  
  def show_all_hands
    show_player
    show_dealer
  end
  
  #Each player gets two cards
  def initial_deal
    dealer.deal_to(player)
    dealer.deal_to(dealer)
    dealer.deal_to(player)
    dealer.deal_to(dealer)
    show_all_hands
    dealer.show_all = true
    dealer.talk = true
  end

  def players_turn  
    while player.hand_value < BLACKJACK
      if player.decide == '2'
        break
      end
      # hit me!
      dealer.deal_to(player)
      player_total = player.hand_value
      puts "Your total is now #{player_total}"
    end
  end

  def dealers_turn
    # Dealer turn
    if dealer.hand_value >= DEALER_LIMIT
      return
    end

    show_dealer
    while dealer.hand_value < DEALER_LIMIT && !(dealer.hand_value >= BLACKJACK)
      # dealer hit
      dealer.deal_to(dealer)
      puts "Dealer total is now: #{dealer.hand_value}"
    end
  end

  def is_out?(participant, opponent)
    if participant.hand_value == BLACKJACK
      puts "#{participant.name}: #{participant}, value= #{participant.hand_value}"
      puts "#{participant.name} hit 21! #{participant.name} wins!"
      true
    elsif participant.hand_value > BLACKJACK
      puts "#{participant.name} is busted! #{opponent.name} wins!"
      true
    else
      false
    end
  end
  
  def check_winner
    if dealer.hand_value > player.hand_value
      puts "Dealer total is greater than player total- dealer wins!"
    elsif dealer.hand_value < player.hand_value
      puts "Congratulations, you win!"
    else
      puts "It's a tie!"
    end
  end
  
  def play_again?
    puts ""
    puts "Play again? 1) yes 2) no"
    if gets.chomp == '1'
      true
    else
      puts "Goodbye!"
      exit
    end
  end

  def play
    loop do 
      initial_deal
      players_turn
      if !is_out?(player, dealer)
        dealers_turn
        if !is_out?(dealer, player)
          show_all_hands    
          check_winner
        end
      end
      play_again?
      puts ""
      puts "New game..."
      @dealer = Dealer.new
      @player = Player.new
    end
  end
end

Game.new.play


