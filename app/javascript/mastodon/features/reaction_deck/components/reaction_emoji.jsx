import PropTypes from 'prop-types';

import { injectIntl } from 'react-intl';

import { List as ImmutableList, Map as ImmutableMap } from 'immutable';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { connect } from 'react-redux';

import { updateReactionDeck } from 'mastodon/actions/reaction_deck';
import EmojiPickerDropdownContainer from 'mastodon/features/compose/containers/emoji_picker_dropdown_container';
import emojify from 'mastodon/features/emoji/emoji';
import { autoPlayGif } from 'mastodon/initial_state';

const MapStateToProps = (state, { emojiId, emojiMap }) => ({
  emoji: (state.get('reaction_deck', ImmutableList()).toArray().find(em => em.get('id') === emojiId) || ImmutableMap({ emoji: { shortcode: '' } })).get('name'),
  emojiMap,
});

const mapDispatchToProps = (dispatch, { emojiId }) => ({
  onChange: (emoji) => dispatch(updateReactionDeck(emojiId, emoji)),
});

class ReactionEmoji extends ImmutablePureComponent {

  static propTypes = {
    emoji: PropTypes.string,
    emojiMap: ImmutablePropTypes.map.isRequired,
    onChange: PropTypes.func.isRequired,
  };

  static defaultProps = {
    emoji: '',
  };

  render () {
    const { emojiMap, emoji, onChange } = this.props;

    let content = null;

    if (emojiMap.get(emoji)) {
      const filename  = autoPlayGif ? emojiMap.getIn([emoji, 'url']) : emojiMap.getIn([emoji, 'static_url']);
      const shortCode = `:${emoji}:`;

      content = (
        <img
          draggable='false'
          className='emojione custom-emoji'
          alt={shortCode}
          title={shortCode}
          src={filename}
        />
      );
    } else {
      const html = { __html: emojify(emoji) };
      content = (
        <span dangerouslySetInnerHTML={html} />
      )
    }

    return (
      <div className='reaction_deck__emoji'>
        <div className='reaction_deck__emoji__wrapper'>
          <EmojiPickerDropdownContainer onPickEmoji={onChange} />
          <div>
            {content}
          </div>
        </div>
      </div>
    );
  }

}

export default connect(MapStateToProps, mapDispatchToProps)(injectIntl(ReactionEmoji));
