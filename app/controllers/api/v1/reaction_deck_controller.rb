# frozen_string_literal: true

class Api::V1::ReactionDeckController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read, :'read:lists' }, only: [:index]
  before_action -> { doorkeeper_authorize! :write, :'write:lists' }, only: [:create]

  before_action :require_user!
  before_action :set_deck, only: [:index, :create]

  rescue_from ArgumentError do |e|
    render json: { error: e.to_s }, status: 422
  end

  def index
    render json: @deck
  end

  def create
    (deck_params['emojis'] || []).each do |data|
      raise ArgumentError if data['id'].to_i >= 16 || data['id'].to_i.negative?

      exists = @deck.find { |dd| dd['id'] == data['id'] }
      if exists
        exists['emoji'] = data['emoji'].delete(':')
      else
        @deck << { id: data['id'], emoji: data['emoji'].delete(':') }
      end
    end
    @deck = @deck.sort_by { |a| a['id'].to_i }
    current_user.settings['reaction_deck'] = @deck.to_json
    current_user.save!

    render json: @deck
  end

  private

  def set_deck
    @deck = current_user.setting_reaction_deck ? JSON.parse(current_user.setting_reaction_deck) : []
  end

  def deck_params
    params
  end
end
