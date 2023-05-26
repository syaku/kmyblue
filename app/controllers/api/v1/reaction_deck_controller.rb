# frozen_string_literal: true

class Api::V1::ReactionDeckController < Api::BaseController
  include RoutingHelper

  before_action -> { doorkeeper_authorize! :read, :'read:lists' }, only: [:index]
  before_action -> { doorkeeper_authorize! :write, :'write:lists' }, only: [:create]

  before_action :require_user!
  before_action :set_deck, only: [:index, :create]

  rescue_from ArgumentError do |e|
    render json: { error: e.to_s }, status: 422
  end

  def index
    render json: remove_metas(@deck)
  end

  def create
    deck = @deck

    (deck_params['emojis'] || []).each do |data|
      raise ArgumentError if data['id'].to_i >= 16 || data['id'].to_i.negative?

      shortcode = data['emoji'].delete(':')
      custom_emoji = CustomEmoji.find_by(shortcode: shortcode, domain: nil)
      custom_emoji_id = custom_emoji&.id
      emoji_data = if custom_emoji
                     {
                       'shortcode' => custom_emoji.shortcode,
                       'url' => full_asset_url(custom_emoji.image.url),
                       'static_url' => full_asset_url(custom_emoji.image.url(:static)),
                       'width' => custom_emoji.image_width,
                       'height' => custom_emoji.image_height,
                     }
                   else
                     {
                       'shortcode' => shortcode,
                     }
                   end

      exists = deck.find { |dd| dd['id'] == data['id'] }
      if exists
        exists['custom_emoji_id'] = custom_emoji_id
        exists['emoji'] = emoji_data
      else
        deck << { 'id' => data['id'], 'custom_emoji_id' => custom_emoji_id, 'emoji' => emoji_data }
      end
    end

    deck = deck.sort_by { |a| a['id'].to_i }
    current_user.settings['reaction_deck'] = deck.to_json
    current_user.save!

    render json: remove_metas(deck)
  end

  private

  def set_deck
    deck = current_user.setting_reaction_deck ? JSON.parse(current_user.setting_reaction_deck) : []
    @deck = remove_unused_custom_emojis(deck)
  end

  def remove_unused_custom_emojis(deck)
    custom_ids = []
    deck.each do |item|
      custom_ids << item['custom_emoji_id'].to_i unless item['custom_emoji_id'].nil?
    end
    custom_emojis = CustomEmoji.where(id: custom_ids)

    deck.each do |item|
      next if item['custom_emoji_id'].nil?

      custom_emoji = custom_emojis.find { |em| em.id == item['custom_emoji_id'].to_i }
      remove = custom_emoji.nil? || custom_emoji.disabled
      item['remove'] = remove if remove
    end
    deck.filter { |item| !item.key?('remove') }
  end

  def remove_metas(deck)
    deck.tap do |d|
      d.each do |item|
        item.delete('custom_emoji_id')
      end
    end
  end

  def deck_params
    params
  end
end
