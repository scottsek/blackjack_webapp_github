require 'rubygems'
require 'sinatra'
require_relative 'blackjack_objects'

set :sessions, true

helpers do
  def card_image(card)
    if card.face_down
      "<img src='/images/cards/cover.jpg' class='card_image'>"
    else
      "<img src='/images/cards/#{card.suit_word}_#{card.rank_word}.jpg' class='card_image'>"
    end 
  end

  def send_message!(current_player)
    blackjack = current_player.has_blackjack?
    busted = current_player.has_busted?
    player_name = current_player.name
    if blackjack or busted then
      @show_buttons = false
      @game_over = true
    end
    case player_name
    when "Dealer"
      if blackjack
        @error = "#{session[:dealer].name} has blackjack"
      elsif busted
        @success = "#{player_name} busted. #{session[:player].name} wins."
      elsif current_player.points_total <= 17
        @show_dealer_hit_button = true
      else
        redirect '/game/compare_hands'
      end
    else
      if blackjack
        @success = "#{session[:player].name} has blackjack" 
      end
      if busted
        @error = "#{session[:player].name} has busted"
      end
    end
  end
end

before do
  @show_buttons = true
end

get '/' do
  session[:player] = nil
  session[:dealer] = nil
  session[:shoe] = nil
  if session[:player]
    redirect '/game'
  else
    redirect '/new_player'
  end
end

get '/new_player' do
  session[:player] = nil
  erb :new_player
end

post '/new_player' do
  if params[:player_name].empty?
    @error = "Name is required"
    halt erb(:new_player)
  end
  session[:player] = Player.new
  session[:player].name = params[:player_name]
  redirect '/game'
end

get '/game' do
  
  session[:shoe] = Shoe.new
  session[:dealer] = Dealer.new
  session[:dealer].name = "Dealer"
  
  #deal cards
  session[:dealer].cards << session[:shoe].deal_face_down
  session[:player].cards << session[:shoe].deal_card
  session[:dealer].cards << session[:shoe].deal_card
  session[:player].cards << session[:shoe].deal_card
  
  if session[:player].has_blackjack?
    @success = "#{session[:player].name} has blackjack"
    @show_buttons = false
    @game_over = true
  end
  erb :game
end
post '/game/same_player' do
  session[:player].cards = []
  redirect '/game'
end

post '/game/player/hit' do
  session[:player].cards << session[:shoe].deal_card
  send_message!(session[:player])
  erb :game
end

get '/game/dealer' do
  @show_buttons = false
  @show_dealer_hit_button = false
  session[:dealer].cards[0].face_down = false
  send_message!(session[:dealer])
  erb :game
end

get '/game/compare_hands' do
  @show_buttons = false
  player_total = session[:player].points_total
  dealer_total = session[:dealer].points_total
  player_name = session[:player].name
  prefix_it = "Dealer has #{dealer_total}. #{player_name} has #{player_total}. #{player_name} "
  if player_total < dealer_total
    @error = "#{prefix_it}  loses."
  elsif player_total > dealer_total
    @success = "#{prefix_it} wins!"
  else
    @success = "#{prefix_it} ties the dealer."
  end
  @game_over = true
  erb :game
end

post '/game/dealer/hit' do
  session[:dealer].cards << session[:shoe].deal_card
  redirect '/game/dealer'
end

post '/game/player/stay' do
  @success = "#{session[:player_name]} is staying."
  @show_buttons = false
  redirect '/game/dealer'
end