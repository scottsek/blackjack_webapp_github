RANK_INDEX = 0
SUIT_INDEX = 1
BLACKJACK_AMOUNT = 21
DEALER_MIN_HIT = 17
ACE_HIGH = 11
ACE_LOW = 1
TEN_OR_FACE = 10
DEFAULT_NUMBER_DECKS = 1

class Card
  attr_accessor :rank, :suit, :face_down

  def initialize(r, s, f_down = false)
    @rank = r
    @suit = s
    @face_down = f_down
  end

  def suit_word
    case suit
    when 'H'
      'Hearts'
    when 'D'
      'Diamonds'
    when 'S'
      'Spades'
    when 'C'
      'Clubs'
    else
      suit
    end
  end

  def rank_word
    case rank
    when '2'..'9'
      rank
    when 'T'
      '10'
    when 'J'
      'Jack'
    when 'Q'
      'Queen'
    when 'K'
      'King'
    when 'A'
      'Ace'
    else
    end
  end

  def to_points
    case rank
    when '2','3','4','5','6','7','8','9'
      rank.to_i
    when 'T','J','Q','K'
      10
    when 'A'
      11
    else
    end
  end
end

class Shoe
  attr_accessor :shoe_cards
  
  SUITS = %w(S H D C)
  RANKS = %w(A 2 3 4 5 6 7 8 9 T J Q K)    

  def initialize(number_of_decks = DEFAULT_NUMBER_DECKS)
    @shoe_cards = []
    number_of_decks.times do
      SUITS.each do |suit|
        RANKS.each do |rank|
          @shoe_cards << Card.new(rank, suit)
        end
      end
    end
    @shoe_cards.shuffle!
  end

  def deal_card(face_down = false)
    one_card = @shoe_cards.pop
    one_card.face_down = face_down
    one_card
  end

  def deal_face_down
    deal_card(true)
  end

  def to_s
    @shoe_cards.inspect
  end
end

module Hand

  def points_total
    total = 0
    ace_counter = 0
    cards.each do |c|
      if !c.face_down
        total = total + c.to_points
        if c.rank == 'A' then ace_counter = 1 end
        #saw the solution on the video, gave me the right 'framework' for the solution, but wanted to try this instead
        while total > BLACKJACK_AMOUNT && ace_counter > 0
          total -= ACE_HIGH - ACE_LOW
          ace_counter -= 1
        end
      end
    end
    total
  end

  def has_busted?
    points_total > BLACKJACK_AMOUNT
  end

  def has_blackjack?
    points_total == BLACKJACK_AMOUNT
  end

end

class Player
  include Hand
  attr_accessor :name, :cards, :hand_state
  def initialize()
    @cards = []
  end
end

class Dealer < Player
  def initialize
    super
  end
  def no_hit?
    points_total >= DEALER_MIN_HIT
  end
end